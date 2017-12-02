require "spec_helper"
require "serverspec"

package = "dovecot"
service = "dovecot"
config_dir = "/etc/dovecot"
ports = [143]
default_owner = "root"
default_group = "root"
base_dir = "/var/run/dovecot"

case os[:family]
when "freebsd"
  config_dir = "/usr/local/etc/dovecot"
  default_group = "wheel"
when "openbsd"
  default_group = "wheel"
end

config = "#{config_dir}/dovecot.conf"
confd_dir = "#{config_dir}/conf.d"

describe package(package) do
  it { should be_installed }
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
