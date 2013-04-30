require 'pushapp/tasks/base'

module Pushapp
  module Tasks
    class ForemanExport < Base

      def run
        logger.info 'Forman exporting...'
      end

      register_as :foreman_export
    end
  end
end