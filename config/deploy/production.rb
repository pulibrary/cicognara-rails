server 'cicognara1.princeton.edu', user: 'deploy', roles: %w(app db web)
server 'cicognara2.princeton.edu', user: 'deploy', roles: %w(app web)
set :deploy_to, '/opt/cicognara/'
set :default_env, fetch(:default_env).merge('RAILS_ENV' => 'production')
