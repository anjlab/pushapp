require 'test_helper'
require 'pushapp/pipe'

class PipeTest < MiniTest::Unit::TestCase

  def test_it_runs_commands
    Pushapp::Pipe.run 'pwd'
  end

  def test_it_raise_exception_if_command_fails
    assert_raises Errno::ENOENT do
      Pushapp::Pipe.run 'unknown command'
    end

    assert_raises Errno::ENOENT do
      Pushapp::Pipe.capture 'unknown command'
    end

    assert_raises RuntimeError do
      Pushapp::Pipe.run 'exit 5'
    end
  end

  def test_it_captures_output
    assert_equal "nice\n", Pushapp::Pipe.capture("echo 'nice'")
  end

end

