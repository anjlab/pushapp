require 'pushapp/tasks/rake'
require 'shellwords'

class Pushapp::Remote

  attr_reader :config
  attr_reader :tasks
  attr_reader :name
  attr_reader :location
  attr_reader :options
  attr_reader :group

  def initialize(name, group, location, config, options = {})
    @name     = name
    @location = location
    @config   = config
    @options  = options
    @group    = group
    @tasks    = Hash.new { |hash, key| hash[key] = [] }
  end

  def full_name
    [group, name].compact.join('-')
  end

  def rake(task_name, task_options={})
    tasks[@event] << Pushapp::Tasks::Rake.new(task_name, merge_options(task_options))
  end

  def script(script_name, script_options={})
    tasks[@event] << Pushapp::Tasks::Script.new(script_name, merge_options(script_options))
  end

  def task(task_name, task_options={})
    tasks[@event] << config.known_task(task_name).new(merge_options(task_options).merge(task_name: task_name))
  end

  def on event, &block
    @event = event.to_s
    instance_eval(&block) if block_given?
  end

  def tasks_on event
    tasks[event.to_s]
  end

  def path
    if host
      @location.match(/:(.*)$/)[1]
    else
      @location
    end
  end

  def host
    host = @location.match(/@(.*):/)
    host[1] unless host.nil?
  end

  def user
    user = @location.match(/(.*)@/)
    user[1] unless user.nil?
  end

  def ssh!
    exec "cd #{path} && #{shell_env} $SHELL -l"
  end

  #
  # Set up Repositories and Hook
  #
  def setup!
    run "#{init_repository} && #{setup_repository}"
  end

  #
  # Update git remote and hook
  #
  def update!
    Pushapp::Hook.new(self).setup
  end

  def exec cmd
    if host
      Kernel.exec "ssh -t #{user}@#{host} '#{cmd}'"
    else
      Kernel.exec cmd
    end
  end

  def env_run cmd
    if host
      Pushapp::Pipe.run "ssh #{user}@#{host} 'cd #{path} && #{shell_env} $SHELL -l -c \"#{cmd}\"'"
    else
      Bundler.with_original_env do
        Pushapp::Pipe.run "cd #{path} && #{shell_env} #{cmd}"
      end
    end
  end

  def run cmd
    if host
      Pushapp::Pipe.run "ssh #{user}@#{host} '#{cmd}'"
    else
      Bundler.with_original_env do
        Pushapp::Pipe.run cmd
      end
    end
  end

  def env
    (options[:env] || {})
  end

  private

  #
  # Initialize an empty repository
  #
  def init_repository
    # Instead of git init with a path, so it does not fail on older
    # git versions (https://github.com/effkay/blazing/issues/53)
    "mkdir #{path}; cd #{path} && git init"
  end

  #
  # Allow pushing to currently checked out branch
  #
  def setup_repository
    "cd #{path} && git config receive.denyCurrentBranch ignore"
  end

  def shell_env
    env.map {|k,v| "#{k}=\"#{Shellwords.escape(v)}\""}.join(" ")
  end

  def merge_options task_options={}
    Pushapp.rmerge(task_options, options).merge(remote: self)
  end

end