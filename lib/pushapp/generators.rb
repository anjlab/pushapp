require 'thor'
require 'awesome_print'
require 'json'

module Pushapp
  class Generators < Thor
    include Thor::Actions
    namespace :generate

    source_root Pushapp::TEMPLATE_ROOT

    class_option :file, default: Pushapp::DEFAULT_CONFIG_LOCATION,
      type: :string, aliases: '-f', banner: 'Specify a pushapp configuration file'

    desc 'web REMOTE', 'generates all configs for REMOTE web (nginx, unicorn and gems)'
    def web(remote)
      options[:remote]
      options[:listen] = "80"

      uncomment_lines 'Gemfile', /gem 'unicorn'/
      uncomment_lines 'Gemfile', /gem 'therubyracer'/
      insert_into_file 'Gemfile', "\ngem 'pushapp'\ngem 'foreman'\ngem 'foreman'\ngem 'dotenv-rails'", after: /gem 'unicorn'/
      unicorn_upstart
      unicorn_nginx(remote)
      unicorn(remote)

      template 'Procfile'
      template '.env.erb', ".env.#{app_env}"
    end

    desc 'unicorn-nginx REMOTE', 'generates nginx config for unicorn'
    method_option :host, desc: 'Nginx host, will use remote host as default.'
    method_option :env,  desc: 'unicorn env, will use remote RAILS_ENV as default.'
    method_option :listen, default: '80', desc: 'Nginx port to listen. Default: 80'

    def unicorn_nginx(remote)
      options[:remote] = remote
      template 'unicorn_nginx.conf.erb', "config/deploys/#{app_name}.nginx.conf"
    end

    desc 'unicorn-upstart', 'generates unicorn binary for upstart/foreman'
    def unicorn_upstart
      template 'unicorn_upstart.erb', 'bin/unicorn_upstart'
      chmod 'bin/unicorn_upstart', 'a+x'
    end

    desc 'unicorn REMOTE', 'generates unicorn config'
    def unicorn(remote)
      options[:remote] = remote
      template 'unicorn.rb.erb', 'config/unicorn.rb'
    end

    desc 'chef-solo REMOTE', 'generates chef solo with knife solo configs'
    method_option :database,
      type: :string,
      default: 'postgresql',
      desc: 'mysql or postgresql',
      aliases: '-d'

    method_option :ssh_pub_key,
      type: :string,
      default: "#{ENV['HOME']}/.ssh/id_rsa.pub"

    method_option :vagrant_box,
      type: :string,
      default: 'opscode_ubuntu-12.04-i386_chef-11.4.4'

    method_option :vagrant_box_url,
      type: :string,
      default: 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04-i386_chef-11.4.4.box'

    method_option :db_password,
      type: :string,
      default: 'password1'

    method_option :ruby,
      type: :string,
      default: '2.0.0-p195'

    def chef_solo(remote)
      options[:remote] = remote

      template 'Cheffile.erb',    'config/deploys/chef/Cheffile'
      template 'Vagrantfile.erb', 'config/deploys/chef/Vagrantfile'
      template 'solo.rb.erb',     'config/deploys/chef/solo.rb'
      template 'node.json.erb',   "config/deploys/chef/nodes/#{app_host}.json"
      template 'user.json.erb',   "config/deploys/chef/data_bags/users/#{app_user}.json"

      template 'chef.gitignore',  'config/deploys/chef/.gitignore'
    end

    private

    def app_name
      remote.path.split('/').last
    end

    def app_user
      remote.user
    end

    def app_host
      options[:host] || remote.host || '127.0.0.1'
    end

    def app_path
      remote.path
    end

    def app_env
      remote.env['RACK_ENV'] || remote.env['RAILS_ENV'] || 'production'
    end

    def remote
      @remote ||= config.remotes_named_by(options[:remote]).first
    end

    def config
      @config ||= Pushapp::Config.parse(options[:file])
    end

    def mysql?
      options[:database] == 'mysql'
    end

    def postgresql?
      options[:database] == 'postgresql'
    end

    def postgresql_config
      {
        config: {
          listen_addresses: "*",
          port: "5432"
        },
        pg_hba: [
          {
            type:   "local",
            db:     "postgres",
            user:   "postgres",
            addr:   nil,
            method: "trust"
          },
          {
            type:   "host",
            db:     "all",
            user:   "all",
            addr:   "0.0.0.0/0",
            method: "md5"
          },
          {
            type:   "host",
            db:     "all",
            user:   "all",
            addr:   "::1/0",
            method: "md5"
          }
        ],
        password: {
          postgres: options[:db_password]
        }
      }
    end

    def mysql_config
      {
        :server_root_password   => options[:db_password],
        :server_repl_password   => options[:db_password],
        :server_debian_password => options[:db_password],
        :service_name           => "mysql",
        :basedir                => "/usr",
        :data_dir               => "/var/lib/mysql",
        :root_group             => "root",
        :mysqladmin_bin         => "/usr/bin/mysqladmin",
        :mysql_bin              => "/usr/bin/mysql",
        :conf_dir               => "/etc/mysql",
        :confd_dir              => "/etc/mysql/conf.d",
        :socket                 => "/var/run/mysqld/mysqld.sock",
        :pid_file               => "/var/run/mysqld/mysqld.pid",
        :grants_path            => "/etc/mysql/grants.sql"
      }
    end

    def authorization_config
      {
        sudo: {
          users: [app_user],
          passwordless: true
        }
      }
    end

    def common_config
      cfg = {
        nginx: {
          dir: "/etc/nginx",
          log_dir: "/var/log/nginx",
          binary: "/usr/sbin/nginx",
          user: "www-data",
          pid: "/var/run/nginx.pid",
          worker_connections: "1024"
        },
        git: {
          prefix: "/usr/local"
        },
      }
      cfg[:mysql] = mysql_config if mysql?
      cfg[:postgresql] = postgresql_config if postgresql?
      cfg
    end

    def chef_config
      common_config.merge({
        authorization: authorization_config,
        rbenv: rbenv_config(app_user)
      })
    end

    def config_json
      chef_config.merge({
        run_list: run_list
      })
    end

    def vagrant_config
      # common_config.merge({
      #   rbenv: rbenv_config('vagrant')
      # })
      chef_config
    end

    def run_list
      [
        'apt',
        'chef-solo-search',
        'locale',
        'users::sysadmins',
        'sudo',
        'runit',
        'memcached',
        mysql? ? 'mysql::server' : nil,
        postgresql? ? 'postgresql::server' : nil,
        'imagemagick',
        'ruby_build',
        'rbenv::user',
        'nginx::repo',
        'nginx',
        'git'
      ].compact
    end

    def user_json
      {
        id:        app_user,
        comment:   'Application User',
        ssh_keys:  [File.read(options[:ssh_pub_key])],
        groups:    %w{sysadmin sudo staff},
        shell:     '/bin/bash'
      }
    end


    def rbenv_config(user)
      {
        user_installs: [{
          user: user,
          rubies: [ options[:ruby] ],
          global: options[:ruby],
          environment: { CFLAGS: "-march=native -O2 -pipe" },
          gems: {
            options[:ruby] => [{name: "bundler", version: "1.3.5"}]
          }
        }]
      }
    end
  end
end