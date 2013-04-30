require 'pushapp/version'

module Pushapp

  autoload :CLI,      'pushapp/cli'
  autoload :Config,   'pushapp/config'
  autoload :Commands, 'pushapp/commands'
  autoload :Shell,    'pushapp/shell'
  autoload :Remote,   'pushapp/remote'
  autoload :Hook,     'pushapp/hook'
  autoload :Git,      'pushapp/git'

  module Tasks
    autoload :Base,   'pushapp/tasks/base'
    autoload :Script, 'pushapp/tasks/script'
    autoload :Rake,   'pushapp/tasks/rake'
  end


  def self.rmerge(a, b)
    r = {}
    a ||= {}
    b ||= {}
    a = a.merge(b) do |key, oldval, newval| 
      r[key] = (Hash === oldval ? rmerge(oldval, newval) : newval)
    end
    a.merge(r)
  end

  DEFAULT_CONFIG_LOCATION = 'config/pushapp.rb'
  TEMPLATE_ROOT = File.expand_path(File.dirname(__FILE__) + File.join('/../templates'))
  TMP_HOOK = '/tmp/post-receive'
end
