require 'pushapp/remote'

class Pushapp::Config

  attr_reader   :file
  attr_reader   :remotes

  @@known_tasks = {}

  def self.parse(configuration_file = nil)
    require 'pushapp/tasks/base'
    require 'pushapp/tasks/script'
    require 'pushapp/tasks/rake'
    require 'pushapp/tasks/upstart'
    require 'pushapp/tasks/nginx_export'
    require 'pushapp/tasks/foreman_export'
    require 'pushapp/tasks/unicorn_signal'

    config = self.new(configuration_file)
    config.instance_eval(File.read(config.file))

    config
  end

  def initialize(configuration_file = nil)
    @file = configuration_file || Pushapp::DEFAULT_CONFIG_LOCATION
    @remotes = []
    @group_options = {}
    @group_name = nil
  end

  def remote(name, location, options = {})
    name = name.to_s

    if remotes.any? {|r| r.location == location}
      raise "Can't have multiple remotes with same location"
    end

    full_name = [name, @group_name].compact.join('-')
    if remotes.any? {|r| r.full_name == full_name}
      raise "Can't have multiple remotes with same full_name. Remote '#{full_name}' already exists"
    end

    options = Pushapp.rmerge(@group_options, options)
    remotes << Pushapp::Remote.new(name, @group_name, location, self, options)
  end

  def group(group_name, options = {}, &block)
    @group_name    = group_name.to_s
    @group_options = options
    instance_eval &block if block_given?
    @group_name = nil
    @group_options = {}
  end

  def on event, &block
    remotes.each {|r| r.on(event, &block) if block_given? }
  end

  def known_task name
    task = @@known_tasks[name.to_s]
    raise "Unkown task with name '#{name}'. Forget to register task?" unless task
    task
  end

  def remotes_named_by(name)
    name = name.to_s
    remotes.select {|r| r.full_name == name }
  end

  def remotes_grouped_by(group)
    group = group.to_s
    remotes.select {|r| r.group == group }
  end

  def remotes_matched(group_or_name)
    case group_or_name
    when 'all'
      remotes
    when String
      remotes.select {|r| r.full_name == group_or_name || r.group == group_or_name}
    when Array
      group_or_name.map {|n| remotes_matched(n)}.flatten.compact.uniq
    else
      []
    end
  end

  def self.register_task name, klass
    @@known_tasks[name.to_s] = klass
  end

end
