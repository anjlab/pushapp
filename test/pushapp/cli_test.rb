require 'test_helper'
require 'pushapp/cli'

class CLITest < MiniTest::Unit::TestCase

  def setup
    @cli = Pushapp::CLI.new
  end

  def test_cli_protocol
    assert @cli.respond_to?(:init)
    assert @cli.respond_to?(:setup)
    assert @cli.respond_to?(:remotes)
    assert @cli.respond_to?(:tasks)
    assert @cli.respond_to?(:trigger)
    assert @cli.respond_to?(:ssh)
    assert @cli.respond_to?(:generate)
    assert @cli.respond_to?(:update_refs)
    assert @cli.respond_to?(:help)
  end

end

