set :application, 'cicognara'
set :repo_url, 'https://github.com/pulibrary/cicognara-rails.git'

# Default branch is :master
set :branch, ENV['BRANCH'] || 'master'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/cicognara'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'vendor/bundle')

# Default value for default_env is {}
set :default_env,
    'MARCPATH' => 'public/cicognara.mrx.xml',
    'TEIPATH' => 'public/catalogo.tei.xml',
    'CATALOGO_VERSION' => 'v2.1'

# Default value for keep_releases is 5
# set :keep_releases, 5
set :passenger_restart_with_touch, true

# Force passenger to use touch tmp/restart.txt instead of
# passenger-config restart-app which requires sudo access
set :passenger_restart_with_touch, true

namespace :deploy do
  desc 'Reindex the TEI entries and MARC records'
  task :reindex do
    on roles(:web), in: :groups, limit: 3, wait: 5 do
      within release_path do
        execute :rake, 'tei:catalogo:update'
        execute :rake, 'tei:index'
      end
    end
  end
end
