require 'logger'
require 'thor'

module Pushapp
  class Logger < ::Logger
    attr_reader :shell

    def initialize
      super($stdout)
      @shell = Thor::Shell::Color.new

      self.progname = '[pushapp]'

              #  DEBUG  INFO    WARN     ERROR FATAL  UNKNOWN
      @colors = {
        'DEBUG'  => :blue,
        'INFO'   => :green,
        'WARN'   => :magenta,
        'ERROR'  => :red,
        'FATAL'  => :red,
        'UNKOWN' => :black
      }

      self.formatter = proc { |severity, datetime, progname, msg|
        color    = @colors[severity]

        progname = @shell.set_color progname, color, :bold
        sev      = @shell.set_color "#{severity}:", color
        msg      = @shell.set_color msg, color
        "#{progname} #{sev} #{msg}\n"
      }
    end
  end
end