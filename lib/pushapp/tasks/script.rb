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

      def env
        Hash[env_options.map {|k, v| [k.to_s, v.to_s] }]
      end

      def env_options
        options[:env] || {}
      end

      def inspect
        "script: #{script}"
      end
    end
  end
end