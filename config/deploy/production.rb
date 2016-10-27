server 'cicognara.princeton.edu', user: 'deploy', roles: %w(app db web)
set :deploy_to, '/opt/rails_app/'
set :default_env, fetch(:default_env).merge('RAILS_ENV' => 'production')
