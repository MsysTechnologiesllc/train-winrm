
require_relative './helper'

require 'train-winrm/transport'
require 'train-winrm/connection'
require 'winrm/output'

describe 'winrm connection' do
  let(:cls) do
    plat = Train::Platforms.name('mock').in_family('windows')
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    TrainPlugins::WinRM::Connection
  end
  let(:conf) {{
    hostname: rand.to_s,
    logger: Logger.new(STDERR, level: :info)
  }}
  describe '#run_command_via_connection through BaseConnection::run_command' do
    let(:winrm) { cls.new(conf) }
    let(:session_mock) {
      session_mock = mock
      session_mock.expects(:run).
        with("test").
        yields('testdata', 'ignored').
        returns(WinRM::Output.new)

      session_mock
    }
    it "invokes the provided block when a block is provided and data is received" do
      called = false
      winrm.expects(:session).returns(session_mock)

      # We need to test run_command b/c run_command_via_connection is private.
      winrm.run_command("test") do |data|
        called = true
        data.must_equal 'testdata'
      end
      called.must_equal true
    end
  end

end

