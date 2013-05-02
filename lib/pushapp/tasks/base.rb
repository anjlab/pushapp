require 'pushapp/config'
require 'pushapp/logger'

module Pushapp
  module Tasks
    class Base
      attr_reader :options
      attr_reader :logger

      def initialize options={}
        @options = options
        @logger = Pushapp::Logger.new
      end

      def run
      end

      def env
        Hash[env_options.map {|k, v| [k.to_s, v.to_s] }]
      end

      def env_options
        options[:env] || {}
      end

      def sudo
        options[:sudo] || 'sudo'
      end

      def system cmd
        Pipe.run cmd
      end

      def app_name_from_path
        options[:remote].path ? options[:remote].path.split('/').last : nil
      end

      def self.register_as name
        Pushapp::Config.register_task name, self
      end

      def inspect
        options[:task_name]
      end
    end
  end
end
