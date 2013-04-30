require 'test_helper'
require 'pushapp/config'
require 'pushapp/tasks/foreman_export'

class ConfigTest < MiniTest::Unit::TestCase

  def setup
    @config = Pushapp::Config.new
  end
  
  def test_takes_the_path_of_the_config_file_as_an_argument
    config = Pushapp::Config.new('/some/where/config.rb')
    assert_equal '/some/where/config.rb', config.file
  end

  def test_takes_the_default_config_path_if_no_path_is_specified
    config = Pushapp::Config.new
    assert_equal 'config/pushapp.rb', config.file
  end

  def test_parse_returns_a_config_object
    assert Pushapp::Config === Pushapp::Config.parse('test/fixtures/empty_config.rb')
  end

  def test_remotes_dsl
    @config.remote :dev, 'app@host:/home/app/app-dev'

    assert_equal 1, @config.remotes.length
    assert_equal 'dev', @config.remotes.first.name
  end

  def test_it_can_group_remotes
    @config.group :dev do
      remote :web,    'app@host1:/home/app/app-dev1'
      remote :worker, 'app@host1:/home/app/app-dev2'
      remote :mailer, 'app@host2:/home/app/app-dev1'
    end

    assert_equal 3, @config.remotes.length
    @config.remotes.each do |r|
      assert Pushapp::Remote === r
    end

    assert_equal 'dev-web',    @config.remotes[0].full_name
    assert_equal 'dev-worker', @config.remotes[1].full_name
    assert_equal 'dev-mailer', @config.remotes[2].full_name
  end

  def test_it_cant_have_remotes_with_same_name_and_location
    @config.remote :dev, 'app@host:/home/app/app-dev'
    assert_raises RuntimeError do
      @config.remote :dev, 'app@host:/home/app/app-dev'
    end
  end

  def test_it_adds_tasks_to_all_remotes
    @config.remote :dev, 'app@host:/home/app/app-dev'
    @config.remote :prod, 'app@host:/home/app/app-prod'

    @config.setup do
      rake 'db:create db:migrate db:seed'      
    end

    @config.update do
      rake 'assets_precompile', env: {rails_group: 'assets'}
      task :foreman_export
    end

    dev  = @config.remotes_named_by(:dev).first
    prod = @config.remotes_named_by(:prod).first

    assert_equal 1, dev.task_list(:setup).length
    assert_equal 1, prod.task_list(:setup).length

    assert_equal 2, dev.task_list(:update).length
    assert_equal 2, prod.task_list(:update).length

    assert_equal 0, dev.task_list(:push).length
    assert_equal 0, prod.task_list(:push).length
  end
end

