# config valid only for Capistrano 3.2.1
lock '3.2.1'

set :application, 'campustheater'

# Server
server 'yfa.org', user: 'ubuntu', roles: [:web, :app, :db]

# Git
set :scm, :git
set :repo_url, 'git@github.com:steve-cmi/campustheater.git'

# Ruby version for RVM - should match .rvmrc
set :rvm_ruby_version, 'ruby-1.9.3-p125'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{Gemfile Gemfile.lock config/analytics.yml config/aws.yml config/database.yml config/email.yml config/ftp.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log tmp public/static public/static_archives public/static_guides}

# Default value for default_env is {}
set :default_env, {
  path: "/usr/local/rvm/gems/ruby-1.9.3-p125/bin:/usr/local/rvm/gems/ruby-1.9.3-p125@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p125/bin:/usr/local/rvm/bin:$PATH",
  gem_path: "/usr/local/rvm/gems/ruby-1.9.3-p125:/usr/local/rvm/gems/ruby-1.9.3-p125@global",
}

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :check do

  desc "Check that we can access everything"
  task :write_permissions do
    on roles(:all) do |host|
      if test("[ -w #{fetch(:deploy_to)} ]")
        info "#{fetch(:deploy_to)} is writable on #{host}"
      else
        error "#{fetch(:deploy_to)} is not writable on #{host}"
      end
    end
  end

  desc "Check if agent forwarding is working"
  task :forwarding do
    on roles(:all) do |h|
      if test("env | grep SSH_AUTH_SOCK")
        info "Agent forwarding is up to #{h}"
      else
        error "Agent forwarding is NOT up to #{h}"
      end
    end
  end

end

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
