require 'thor'
require 'pushapp/commands'

module Pushapp
  class CLI < Thor

    default_task :help

    desc 'init', 'Generate a pushapp config file'

    def init
      Pushapp::Commands.run(:init)
    end

    desc 'setup REMOTES', 'Setup group or remote repository/repositories for deployment'

    method_option :file, type: :string, aliases: '-f', banner:  'Specify a configuration file'

    def setup(*remotes)
      Pushapp::Commands.run(:setup, remotes: remotes, options: options)
    end

    desc 'update-refs', 'Setup remote refs in local .git/config'

    method_option :file, type: :string, aliases: '-f', banner: 'Specify a configuration file'

    def update_refs
      Pushapp::Commands.run(:update_refs, options: options)
    end

    desc 'update REMOTES', 'Re-Generate and upload hook based on current configuration'

    method_option :file, type: :string, aliases: '-f', banner: 'Specify a configuration file'

    def update(*remotes)
      Pushapp::Commands.run(:update, remotes: remotes, options: options)
    end

    desc 'remotes', 'List all known remotes'

    method_option :file, type: :string, aliases: '-f', banner: 'Specify a configuration file'

    def remotes
      Pushapp::Commands.run(:list_remotes, options: options)
    end

    desc 'tasks REMOTES', 'Show tasks list for remote(s). Default: all'

    def tasks(*remotes)
      Pushapp::Commands.run(:tasks, remotes: remotes, options: options)
    end

    desc 'trigger EVENT REMOTES', 'Triggers event on remote(s)'

    method_option :file, type: :string, aliases: '-f', banner: 'Specify a configuration file'
    method_option :local, type: :boolean, default: false, aliases: '-l', banner: 'Specify a configuration file'

    def trigger(event, *remotes)
      Pushapp::Commands.run(:trigger, event: event, remotes: remotes, local: options['local'], options: options)
    end

    desc 'ssh REMOTE', 'SSH to remote and setup ENV vars.'

    method_option :file, type: :string, aliases: '-f', banner: 'Specify a configuration file'

    def ssh(remote=nil)
      Pushapp::Commands.run(:ssh, remote: remote, options: options)
    end
  end
end
