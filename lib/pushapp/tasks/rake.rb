require 'pushapp/tasks/script'

module Pushapp
  module Tasks
    class Rake < Script
      def cmd
        [env, "rake #{script}"]
      end

      def inspect
        "rake: #{script}"
      end
    end
  end
end