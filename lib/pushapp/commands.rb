require 'erb'

module Pushapp
  class Commands

    def self.run(command, options = {})
      self.new(options.merge({ command: command })).send(command)
    end    

    def initialize(options = {})
      @options = options
    end

    def init
      # info "Creating an example config file in #{Pushapp::DEFAULT_CONFIG_LOCATION}"
      # info "Customize it to your needs"
      create_config_directory
      write_config_file
    end

    def update_refs
      Pushapp::Git.new.update_tracked_repos(config)
    end

    def setup
      remotes.each { |r| r.setup! }
      update
    end

    def update
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
      if @options[:local]
        shell = Pushapp::Shell.new
        remotes.each do |r|
          r.tasks_on(event).each do |t|
            shell.run(t)
          end
        end
      else
        remotes.each {|r| r.run "bundle exec pushapp trigger #{event} #{r.full_name} -l true"}
      end
    end

    def ssh
      if remote
        remote.ssh!   
      else
        puts 'error'
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

