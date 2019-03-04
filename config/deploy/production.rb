server 'cicognara1.princeton.edu', user: 'deploy', roles: %w(app db web)
set :deploy_to, '/opt/cicognara/'
set :default_env, fetch(:default_env).merge('RAILS_ENV' => 'production')
