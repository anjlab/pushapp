require 'erb'

module Pushapp
  class Commands
    attr_reader :logger

    def self.run(command, options = {})
      self.new(options.merge({ command: command })).send(command)
    end

    def initialize(options = {})
      @options = options
      @logger = Pushapp::Logger.new
    end

    def init
      logger.info "Creating an example config file in #{Pushapp::DEFAULT_CONFIG_LOCATION}"
      logger.info "Customize it to your needs"
      create_config_directory
      write_config_file
    end

    def update_refs
      logger.info "Updating .git/config. Setting up refs to all remotes"
      Pushapp::Git.new.update_tracked_repos(config)
    end

    def list_remotes
      logger.info "Known remotes:"
      remotes_table = config.remotes.map {|r| [r.full_name, r.location, r.env]}
      remotes_table.unshift ['Full Name', 'Location', 'ENV']
      logger.shell.print_table(remotes_table)
    end

    def setup
      logger.info "Setting up remotes"
      remotes.each { |r| r.setup! }
      update
    end

    def update
      logger.info "Updating remotes"
      remotes.each { |r| r.update! }
    end

    def tasks
      remotes_list = remotes.empty? ? config.remotes : remotes
      remotes_list.each do |r|
        puts "REMOTE: #{r.full_name}"
        r.tasks.keys.each do |event|
          puts "    EVENT: #{event}"
          r.tasks[event].each do |task|
            puts "        #{task.inspect}"
          end
        end
      end
    end

    def trigger
      event = @options[:event]
      local = @options[:local]
      if local
        logger.info "STARTING TASKS ON EVENT #{event}"
        remotes.each do |r|
          r.tasks_on(event).each do |t|
            logger.info "run: #{t.inspect}"
            Pushapp::Pipe.run(t)
          end
        end
      else
        remotes.each {|r| r.env_run "bundle exec pushapp trigger #{event} #{r.full_name} -l true"}
      end
    end

    def ssh
      if remote
        remote.ssh!
      else
        logger.error 'Remote not found'
      end
    end

    private

    def remote
      @remote ||= config.remotes_named_by(@options[:remote]).first
    end

    def remotes
      @remotes ||= config.remotes_matched(@options[:remotes])
    end

    def config
      @config ||= Pushapp::Config.parse(@config_file)
    end

    def create_config_directory
      Dir.mkdir 'config' unless File.exists? 'config'
    end

    def write_config_file
      config = ERB.new(File.read("#{Pushapp::TEMPLATE_ROOT}/config.rb.erb")).result
      File.open(Pushapp::DEFAULT_CONFIG_LOCATION,"wb") { |f| f.puts config }
    end
  end
end

