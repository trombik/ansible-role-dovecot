require "spec_helper"
require "serverspec"

package = "dovecot"
extra_packages = []
service = "dovecot"
config_dir = "/etc/dovecot"
ports = [143]
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
when "ubuntu"
  package = "dovecot-core"
  extra_groups = ["nogroup"]
  extra_packages = ["dovecot-imapd"]
end

config = "#{config_dir}/dovecot.conf"
confd_dir = "#{config_dir}/conf.d"

describe package(package) do
  it { should be_installed }
end

extra_packages.each do |p|
  describe package p do
    it { should be_installed }
  end
end

describe user(user) do
  it { should exist }
  extra_groups.each do |g|
    it { should belong_to_group g }
  end
end

describe file(confd_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by default_owner }
  it { should be_grouped_into default_group }
  it { should be_mode 755 }
end

["auth.conf"].each do |f|
  describe file("#{confd_dir}/#{f}") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_owner }
    it { should be_grouped_into default_group }
    it { should be_mode 640 }
    case f
    when "auth.conf"
      its(:content) { should match(/^disable_plaintext_auth = no$/) }
      passdb_driver = case os[:family]
                      when "openbsd"
                        "bsdauth"
                      else
                        "pam"
                      end

      its(:content) { should match(/^passdb {\n\s+driver = #{passdb_driver}\n}\nuserdb {\n\s+driver = passwd\n}$/) }
    end
  end
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_owner }
  it { should be_grouped_into default_group }
  it { should be_mode 644 }
  its(:content) { should match(/^protocols = imap$/) }
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

describe port(993) do
  it { should_not be_listening }
end

# XXX use rspec-retry as somtimes initial attempt fails
describe "IMAP banner", retry: 10, retry_wait: 1 do
  it "displays the expected banner" do
    imap_banner_text = case os[:family]
                       when "ubuntu"
                         "* OK [CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE AUTH=PLAIN] Dovecot (Ubuntu) ready."
                       when "freebsd", "openbsd"
                         "* OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE LITERAL+ AUTH=PLAIN] Dovecot ready."
                       else
                         raise "Unknown os[:family]: `#{os[:family]}`"
                       end
    nc_flags = os[:family] == "ubuntu" ? "" : "-N"
    r = command "echo -n | nc #{nc_flags} localhost 143"

    expect(r.exit_status).to eq 0
    expect(r.stderr).to eq ""
    expect(r.stdout).to match(/^#{Regexp.escape(imap_banner_text)}$/)
  end
end
