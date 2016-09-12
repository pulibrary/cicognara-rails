server 'libruby-dev.princeton.edu', user: 'deploy', roles: %w(app web)

set :default_env, fetch(:default_env).merge('RAILS_ENV' => 'staging')
