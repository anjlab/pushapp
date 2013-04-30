require 'erb'

module Pushapp
  class Hook

    ANSI_COLORS = {
      :reset          => 0,
      :black          => 30,
      :red            => 31,
      :green          => 32,
      :yellow         => 33,
      :blue           => 34,
      :magenta        => 35,
      :cyan           => 36,
      :white          => 37,
      :bright_black   => 30,
      :bright_red     => 31,
      :bright_green   => 32,
      :bright_yellow  => 33,
      :bright_blue    => 34,
      :bright_magenta => 35,
      :bright_cyan    => 36,
      :bright_white   => 37,
    }

    HOOK_COLORS = %w( cyan yellow green magenta blue bright_cyan bright_yellow
                      bright_magenta bright_blue red bright_green bright_red )

    attr_accessor :remote

    def initialize(remote)
      @remote  = remote      
      @config  = remote.config
      @options = remote.options

      @remote_index = @config.remotes.index(@remote)
      @remote_color = ANSI_COLORS[HOOK_COLORS[@remote_index % HOOK_COLORS.length].to_sym]
      @echo_color   = ANSI_COLORS[:bright_green]
      @error_color  = ANSI_COLORS[:bright_red]
    end

    def setup
      prepare_hook
      deploy_hook
    end

    private

    def padded_max_length
      if @remote.group
        @config.remotes_grouped_by(@remote.group).map {|r| r.full_name}.max.length
      else
        @remote.name.length
      end
    end

    def padded_name
      @padden_name ||= @remote.full_name.ljust([padded_max_length, "remote:".length].max)
    end

    def prefix
      "\e[1G\e[#{@remote_color}m#{padded_name} |\e[0m "
    end

    def pre
      "#\{ENV[\"PAP_PRE\"]\}"
    end

    def colorize
      %{2>&1 | ruby -pe '$_="#{pre}#\{$_\}"'}
    end

    def echo message
      %{ruby -e 'puts "#{pre}\e[#{@echo_color}m#{message}\e[0m"'}
    end

    def load_template(template_name)
      ::ERB.new(File.read(find_template(template_name))).result(binding)
    end

    def find_template(template_name)
      "#{Pushapp::TEMPLATE_ROOT}/#{template_name}.erb"
    end

    def prepare_hook
      # info "Generating and uploading post-receive hook for #{@remote.name}"
      hook = generate_hook
      write hook
    end

    def deploy_hook
      # debug "Copying hook for #{@remote.name} to #{@remote.location}"
      copy_hook
      set_hook_permissions
    end

    def generate_hook
      load_template 'hook/base'
    end

    def write(hook)
      File.open(Pushapp::TMP_HOOK, "wb") do |f|
        f.puts hook
      end
    end

    def set_hook_permissions
      @remote.run "#{make_hook_executable}"
    end

    def copy_hook
      # debug "Making hook executable"
      # TODO: handle missing user?
      if @remote.host
        Pipe.run "scp #{Pushapp::TMP_HOOK} #{@remote.user}@#{@remote.host}:#{@remote.path}/.git/hooks/post-receive"
      else
        Pipe.run "cp #{Pushapp::TMP_HOOK} #{@remote.path}/.git/hooks/post-receive"
      end
    end

    def make_hook_executable
      # debug "Making hook executable"
      "chmod +x #{@remote.path}/.git/hooks/post-receive"
    end
  end
end

