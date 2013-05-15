# pushapp

Simple heroku like deployment system.

TODO: notes on blazing

## Installation

Add this line to your application's Gemfile:

    gem 'pushapp'

## Usage

add ./vendor/bundle to .gitignore

## Supported tasks

 - :unicorn_signal - sends USR2 signal to tmp/pids/unicorn.pid
 - :foreman_export - foreman export (upstart is default)
 - :upstart_start - start upstart job
 - :upstart_stop - stop upstart job
 - :upstart_restart - restart upstart job
 - :whenever_update - whenever update (crontab)
 - :nginx_export - copy nginx site config to nginx/sites_enabled

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
