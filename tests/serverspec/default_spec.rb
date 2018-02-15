require "spec_helper"
require "serverspec"

package = "dovecot"
service = "dovecot"
config_dir = "/etc/dovecot"
ports = [993]
user = "dovecot"
default_owner = "root"
default_group = "root"
base_dir = "/var/run/dovecot"
extra_groups = ["nobody"]

case os[:family]
when "freebsd"
  config_dir = "/usr/local/etc/dovecot"
  default_group = "wheel"
when "openbsd"
  default_group = "wheel"
  user = "_dovecot"
end

config = "#{config_dir}/dovecot.conf"
confd_dir = "#{config_dir}/conf.d"
ssl_cert_dir = "#{config_dir}/ssl"

describe package(package) do
  it { should be_installed }
end

describe user(user) do
  it { should exist }
  extra_groups.each do |g|
    it { should belong_to_group g }
  end
end

["dovecot_pub.pem", "dovecot_key.pem"].each do |f|
  describe file("#{ssl_cert_dir}/#{f}") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by user }
    it { should be_grouped_into default_group }
    case f
    when "dovecot_key.pem"
      it { should be_mode 400 }
      its(:content) { should match(/^-----BEGIN RSA PRIVATE KEY-----$/) }
    when "dovecot_pub.pem"
      it { should be_mode 444 }
      its(:content) { should match(/^-----BEGIN CERTIFICATE-----$/) }
    end
  end
end

describe file(confd_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by default_owner }
  it { should be_grouped_into default_group }
  it { should be_mode 755 }
end

["auth.conf", "ssl.conf"].each do |f|
  describe file("#{confd_dir}/#{f}") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_owner }
    it { should be_grouped_into default_group }
    it { should be_mode 640 }
    case f
    when "auth.conf"
      its(:content) { should match(/^disable_plaintext_auth = yes$/) }
      passdb_driver = case os[:family]
                      when "openbsd"
                        "bsdauth"
                      else
                        "pam"
                      end

      its(:content) { should match(/^passdb {\n\s+driver = #{passdb_driver}\n}\nuserdb {\n\s+driver = passwd\n}$/) }
    when "ssl.conf"
      its(:content) { should match(/^ssl = required$/) }
      its(:content) { should match(/^ssl_cert = <#{Regexp.escape("#{config_dir}/ssl/dovecot_pub.pem")}$/) }
      its(:content) { should match(/^ssl_key = <#{Regexp.escape("#{config_dir}/ssl/dovecot_key.pem")}$/) }
    end
  end
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_owner }
  it { should be_grouped_into default_group }
  it { should be_mode 644 }
  its(:content) { should match(/^protocols = imaps$/) }
  its(:content) { should match(/^listen = \*$/) }
  its(:content) { should match(/^base_dir = "#{Regexp.escape(base_dir)}"$/) }
  ["auth.conf"].each do |conf|
    its(:content) { should match(/^!include #{Regexp.escape(confd_dir + "/#{conf}")}$/) }
  end
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/dovecot") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_owner }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^dovecot_config="#{config}"$/) }
    its(:content) { should match(/^dovecot_flags=""$/) }
  end
when "openbsd"
  describe file("/etc/login.conf") do
    it { should be_file }
    its(:content) { should match(/^dovecot:\\\n\s+:openfiles-cur=512:\\\n\s+:openfiles-max=2048:\\\n\s+:tc=daemon:$/) }
  end

  describe command("rcctl get #{service} flags") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "" }
    its(:stderr) { should eq "" }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe port(143) do
  it { should_not be_listening }
end

stderr_text = "depth=0 C = TH, ST = Bangkok, O = Internet Widgits Pty Ltd, CN = a.mx.trombik.org
verify error:num=18:self signed certificate
verify return:1
depth=0 C = TH, ST = Bangkok, O = Internet Widgits Pty Ltd, CN = a.mx.trombik.org
verify return:1
DONE\n"
describe command("echo | openssl s_client -connect localhost:imaps") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq stderr_text }
  its(:stdout) { should match(/^#{Regexp.escape("* OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE AUTH=PLAIN] Dovecot ready.")}$/) }
  its(:stdout) { should match(/^#{Regexp.escape("subject=/C=TH/ST=Bangkok/O=Internet Widgits Pty Ltd/CN=a.mx.trombik.org")}$/) }
  its(:stdout) { should match(/^#{Regexp.escape("issuer=/C=TH/ST=Bangkok/O=Internet Widgits Pty Ltd/CN=a.mx.trombik.org")}$/) }
end
