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

      def self.register_as name
        Pushapp::Config.register_task name, self
      end

      def inspect
        options[:task_name]
      end
    end
  end
end
