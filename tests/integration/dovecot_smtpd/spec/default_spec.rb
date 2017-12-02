require_relative "spec_helper"
require "net/imap"

class ServiceNotReady < StandardError
end

sleep 10 if ENV["JENKINS_HOME"]

describe server(:server1) do |_s|
  let(:imap) { Net::IMAP.new(server(:server1).server.address) }
  it "authenticates valid user" do
    expect { imap.authenticate("PLAIN", "john@example.org", "PassWord") }.not_to raise_exception
  end
end
