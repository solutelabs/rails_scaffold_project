# frozen_string_literal: true

require 'mina/multistage'
require 'mina/rails'
require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv' # for rbenv support. (https://rbenv.org)
require 'mina/puma'
require 'mina_sidekiq/tasks'
# require 'mina/rvm'    # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

# set :rails_env, 'staging'
set :application_name, 'yourappname'
set :forward_agent, true
set :identity_file, ENV['PRIVATE_KEY']
set :keep_releases, 3

set :shared_files, [
  'tmp',
  'log',
  'config/master.key'
]

set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/pids', 'tmp/sockets', 'public/uploads')
# set :puma_config, "#{fetch(:deploy_to)}/current/config/puma.rb"

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0 --skip-existing}
  # command %(rbenv install 2.4.1 --skip-existing)
  command %(mkdir -p "#{fetch(:shared_path)}")

  command %(mkdir -p "#{fetch(:shared_path)}/log")
  command %(chmod g+rx,u+rwx "#{fetch(:shared_path)}/log")

  command %(mkdir -p "#{fetch(:shared_path)}/tmp")
  command %(chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp")

  command %(mkdir -p "#{fetch(:shared_path)}/config")
  command %(chmod g+rx,u+rwx "#{fetch(:shared_path)}/config")
  command %(touch "#{fetch(:shared_path)}/config/database.yml")

  command %(mkdir -p "#{fetch(:deploy_to)}/shared/pids/")

  command %(mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/sockets")
  command %(chmod g+rx,u+rwx "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/sockets")
  command %(mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/pids")
  command %(chmod g+rx,u+rwx "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/pids")
end

desc "Deploys the current version to the server."
task deploy: :remote_environment do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'sidekiq:quiet'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    # invoke :'rails:db_migrate:primary'
    # invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        invoke :'puma:restart'
        command "sleep 1"
        invoke :'sidekiq:restart'
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end
