require 'bundler/capistrano'
require "rvm/capistrano"
require "whenever/capistrano"

set :application, "teamspeak-history"
set :scm, :git
set :repository,  "https://github.com/macrouch/teamspeak-history.git"
set :shallow_clone, 1

set :user, "web"
set :use_sudo, false
set :rvm_type, :system
set :whenever_command, "bundle exec whenever"

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "web_id_rsa")]
ssh_options[:port] = 2242

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

server "sleekcoder.com", :app, :web, :db, :primary => true
set :deploy_to, "/home/web/sites/teamspeak-history"

# role :web, "sleekcoder.com"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
before "deploy:migrate", "shared:database"
after "deploy:update_code", "deploy:migrate"
after "deploy:update_code", "whenever:update_crontab"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :shared do
	desc 'Link a shared database directory'
	task :database do
		run "ln -sf #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
		run "touch #{shared_path}/db/production.sqlite3"
	end
end