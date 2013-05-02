require 'pushapp/tasks/base'

module Pushapp
  module Tasks
    class NginxExport < Base
      def run
        system "#{sudo} cp #{nginx_conf} #{nginx_sites}"

        unless options[:nginx_skip_reload]
          system "#{sudo} /etc/init.d/nginx reload"
        end
      end

      register_as :nginx_export

      private

      def nginx_conf
        options[:nginx_conf] || find_nginx_conf
      end

      def nginx_sites
        options[:nginx_sites] || '/etc/nginx/sites-enabled'
      end

      def find_nginx_conf
        file = "config/deploys/#{app_name_from_path}.nginx.conf"
        return file if File.exists?(file)
      end
    end
  end
end