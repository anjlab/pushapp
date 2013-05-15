require 'pushapp/tasks/base'

module Pushapp
  module Tasks
    class WheneverUpdate < Base

      def run
        system "#{sudo} bundle exec whenever --update-crontab #{whenever_app} --set #{variables}"
      end

      private

      def whenever_app
        options[:whenever_app] || app_name_from_path
      end

      def rails_env
        env['RAILS_ENV']
      end

      def variables
         "environment=#{rails_env}"
      end

      register_as :whenever_update
    end
  end
end