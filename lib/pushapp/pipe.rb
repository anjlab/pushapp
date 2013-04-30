require 'open3'
require 'stringio'

module Pushapp
  class Pipe

    def self.run(command)
      case command
      when String
        pipe(command)
      when Pushapp::Tasks::Script
        pipe(command.cmd)
      when Pushapp::Tasks::Base
        command.run
      when Array
        pipe(command)
      else
        raise "Unknown command format: '#{command.inspect}'"
      end
    end

    def self.capture(cmd)
      output, s = Open3.capture2e(cmd)
      raise "Failed with status #{s.exitstatus}: #{cmd.inspect}" unless s.success?
      output
    end

    private

    def self.pipe cmd, stdin=$stdin, stdout=$stdout
      s = Open3.pipeline(cmd, :in => stdin, :out => stdout).last
      raise "Failed with status #{s.exitstatus}: #{cmd.inspect}" unless s.success?
    end
  end
end