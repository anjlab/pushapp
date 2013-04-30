require 'test_helper'
require 'pushapp/shell'

class ShellTest < MiniTest::Unit::TestCase

  def setup
    @shell = Pushapp::Shell.new
  end

  def test_it_runs_commands
    @shell.run 'pwd'
  end

  def test_it_raise_exception_if_command_fails
    assert_raises Errno::ENOENT do
      @shell.run 'unknown command'
    end

    assert_raises Errno::ENOENT do
      @shell.capture 'unknown command'
    end

    assert_raises RuntimeError do
      @shell.run 'exit 5'
    end
  end

  def test_it_captures_output
    assert_equal "nice\n", @shell.capture("echo 'nice'")
  end

end

