require 'test_helper'
require 'pushapp/cli'

class CLITest < MiniTest::Unit::TestCase

  def setup
    @cli = Pushapp::CLI.new
  end

  def test_it_has_init_method
    @cli.respond_to? :init
  end

  def test_it_has_setup_method
    @cli.respond_to? :setup
  end

  def test_it_has_update_method
    @cli.respond_to? :update
  end

  def test_it_has_help_method
    @cli.respond_to? :help
  end

end

