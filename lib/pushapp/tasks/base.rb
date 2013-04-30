require 'pushapp/config'

module Pushapp
  module Tasks
    class Base
      attr_reader :options

      def initialize options={}
        @options = options
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
