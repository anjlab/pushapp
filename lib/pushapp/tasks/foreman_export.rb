require 'pushapp/tasks/base'

module Pushapp
  module Tasks
    class ForemanExport < Base

      def run
        system "#{sudo} bundle exec foreman export #{arguments}"
      end

      private

      def arguments
        args = ["#{foreman_format} #{foreman_location}"]
        args << "-f #{foreman_procfile}" if foreman_procfile
        args << "-a #{foreman_app}" if foreman_app
        args << "-u #{foreman_user}" if foreman_user
        args << "-d #{foreman_directory}" if foreman_directory
        args << "-e #{foreman_env}" if foreman_env
        args << "-l #{foreman_log}"
        args << "-p #{options[:foreman_port]}" if options[:foreman_port]
        args << "-c #{options[:foreman_concurrency]}" if options[:foreman_concurrency]
        args << "-t #{options[:foreman_template]}" if options[:foreman_template]
        args.join(' ')
      end

      def foreman_format
        options[:foreman_format] || "upstart"
      end

      def foreman_location
        options[:foreman_location] || foreman_format == 'upstart' ? '/etc/init' : nil
      end

      def foreman_procfile
        options[:foreman_procfile] || find_procfile
      end

      def foreman_app
        options[:foreman_app] || app_name_from_path
      end

      def foreman_user
        options[:foreman_user] || options[:remote].user
      end

      def foreman_directory
        options[:foreman_directory] || options[:remote].path
      end

      def foreman_env
        options[:foreman_env] || find_dot_env_file
      end

      def foreman_log
        options[:foreman_log] || 'log/foreman'
      end

      def find_dot_env_file
        dot_env = ['.env', rails_env].compact.join('.')
        return dot_env if File.exists?(dot_env)
        return '.env' if File.exists?('.env')
      end

      def find_procfile
        procfile = ['config/deploys/Procfile', rails_env].join('.')
        return procfile if File.exists?(procfile)
        procfile = ['Procfile', rails_env].join('.')
        return procfile if File.exists?(procfile)
      end

      def rails_env
        env['RAILS_ENV']
      end

      register_as :foreman_export
    end
  end
end