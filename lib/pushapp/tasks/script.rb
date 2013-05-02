require 'pushapp/tasks/base'

module Pushapp
  module Tasks
    class Script < Base
      attr_reader :script

      def initialize script, options={}
        super(options)

        @script = script
      end

      def cmd
        [env, script]
      end

      def inspect
        "script: #{script}"
      end
    end
  end
end