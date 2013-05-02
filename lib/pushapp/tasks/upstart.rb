require 'pushapp/tasks/base'

module Pushapp
  module Tasks
    class Upstart < Base
      def upstart_job
        @upstart_job ||= options[:upstart_job] || job_name_from_path
      end

      def upstart_jobs
        options[:upstart_jobs] || []
      end

      def job_name_from_path
        options[:remote].path ? options[:remote].path.split('/').last : nil
      end

      def jobs
        @jobs ||= upstart_jobs.empty? ? [upstart_job] : upstart_jobs.map {|j| [upstart_job, j].compact.join("-")}
      end

      def run
        jobs.each { |j| run_on(j) }
      end

      def run_on job
      end
    end

    class UpstartStart < Upstart
      def run_on job
        system "#{sudo} initctl start #{job}"
      end

      register_as :upstart_start
    end

    class UpstartStop < Upstart
      def run_on job
        system "#{sudo} initctl stop #{job}"
      end

      register_as :upstart_stop
    end

    class UpstartRestart < Upstart
      def run_on job
        system "#{sudo} initctl start #{job} || initctl restart #{job}"
      end

      register_as :upstart_restart
    end

    class UpstartReload < Upstart
      def run_on job
        system "#{sudo} initctl start #{job} || initctl restart #{job}"
      end

      register_as :upstart_reload
    end
  end
end