require 'test_helper'
require 'pushapp/remote'

class RemoteTest < MiniTest::Unit::TestCase

  def setup
    remote_options = {
      default_option: 5,
      env: {RAILS_ENV: 'production'}
    }
    @remote = Pushapp::Remote.new('test', nil, 'tmp', Pushapp::Config.new, remote_options)
  end

  def test_task_options_override_remote_options
    @remote.on :push do
      rake('test1', task_option: 'task option', env: {RAILS_ENV: 'test'})
      rake('test2')
    end

    task1 = @remote.tasks_on(:push).first

    assert task1
    assert task1.options[:task_option] == 'task option'
    assert task1.options[:default_option] == 5
    assert task1.options[:env][:RAILS_ENV] == 'test'

    task2 = @remote.tasks_on(:push).last

    assert task2
    assert task2.options[:task_option] == nil
    assert task2.options[:default_option] == 5
    assert task2.options[:env][:RAILS_ENV] == 'production'
  end

end

