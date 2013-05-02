require 'pushapp/tasks/base'

module Pushapp
  module Tasks
    class UnicornRestart < Base
      def run
        pid = unicorn_pid
        if pid
          logger.info "sending #{unicorn_signal} to pid at #{unicorn_pid_file}"
          system "cp -f #{unicorn_pid_file} #{unicorn_pid_file}.oldpid"
          system "#{sudo} kill -#{unicorn_signal} #{unicorn_pid}"
        else
          logger.warn "can't find unicorn pid at '#{unicorn_pid_file}'"
        end
      end

      register_as :unicorn_restart

      private

      def unicorn_pid
        File.exists?(unicorn_pid_file) ? File.read(unicorn_pid_file).to_i : nil
      end

      def unicorn_pid_file
        options[:unicorn_pid_file] || "tmp/pids/unicorn.pid"
      end

      def unicorn_signal
        "#{options[:unicorn_signal] || :usr2}".upcase
      end
    end
  end
end