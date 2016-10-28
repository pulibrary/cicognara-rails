server 'libruby-dev.princeton.edu', user: 'deploy', roles: %w(app web db)

set :default_env, fetch(:default_env).merge('RAILS_ENV' => 'staging', 'URL_PATH' => 'cicognara/')
set :linked_files, fetch(:linked_files, []).push('db/staging.sqlite3')
