# pushapp

Simple heroku like deployment system.

<a href='https://vimeo.com/66528056'><img src="https://f.cloud.github.com/assets/5250/523884/d78a70e0-c0e8-11e2-8569-09e00d48a693.gif" width="512"></a>

[full video](https://vimeo.com/66528056)

TODO: notes on blazing

## Installation

Add this line to your application's Gemfile:

    gem 'pushapp'

## Usage

add ./vendor/bundle to .gitignore

## Supported commands

 - `init` - generates pushapp config file
 - `remotes` - list all known remotes
 - `setup` - setup group or remote repository/repositories for deployment
 - `generate` - bootstrapp app with various optimized configs
 - `update-refs` - setup remote refs in local .git/config
 - `tasks` - show tasks list for remote(s)
 - `trigger` - triggers event on remote(s)
 - `ssh` - SSH to remote and setup ENV vars
 - `exec` - run shell command remotely

Run `pushapp help` to list all available commands and options.

## Supported tasks

 - `unicorn_signal` - sends USR2 signal to tmp/pids/unicorn.pid
 - `foreman_export` - foreman export (upstart is default)
 - `upstart_start` - start upstart job
 - `upstart_stop` - stop upstart job
 - `upstart_restart` - restart upstart job
 - `whenever_update` - whenever update (crontab)
 - `nginx_export` - copy nginx site config to nginx/sites_enabled

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
