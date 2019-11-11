# Cicognara

An application for indexing and displaying IIIF Manifests from multiple partners
in an effort to create a high quality digital version of Count Leopoldo Cicognara's private
book collection.

[![CircleCI](https://circleci.com/gh/pulibrary/cicognara-rails.svg?style=svg)](https://circleci.com/gh/pulibrary/cicognara-rails)
[![Coverage Status](https://coveralls.io/repos/pulibrary/cicognara-rails/badge.svg?branch=master&service=github)](https://coveralls.io/github/pulibrary/cicognara-rails?branch=master)


## Initial Setup

```sh
git clone https://github.com/pulibrary/cicognara-rails.git
cd cicognara-rails
bundle install
```

Remember you'll need to run `bundle install` on an ongoing basis as dependencies are updated.


## Setup server

1. For test:
   - `RAILS_ENV=test rake db:setup`
   - `rake test_server`
   - In a separate terminal: `bundle exec rspec`
2. For development:
   - `rake db:setup`
   - `rake server`
     - This will run Solr/Index Example Records/Launch a web server.
   - Access at http://localhost:3000/
   - Log in once
   - Become an admin with `rake set_admin_role`
     - You can also specify an email address to make a user an admin:
       `EMAIL=user@example.org rake set_admin_role`

## Index/Generate Partials for full Catalogo:

1. Ensure Development server is running
2. `cd tmp`
3. `git clone git@github.com:pulibrary/cicognara-catalogo.git`
4. `cd ..`
5. `TEIPATH=tmp/cicognara-catalogo/catalogo.tei.xml MARCPATH=tmp/cicognara-catalogo/cicognara.mrx.xml rake tei:index`
6. `TEIPATH=tmp/cicognara-catalogo/catalogo.tei.xml rake tei:partials`

## Indexing Full Manifests from Getty

1. Ensure full Catalogo is indexed (see above)
2. `rake getty:import`

## Deploying:
When deploying, make sure the desired cicognara-catalogo (MARC and TEI) release is specified:
```
# config/deploy.rb`
set :default_env,
    'MARCPATH' => 'public/cicognara.mrx.xml',
    'TEIPATH' => 'public/catalogo.tei.xml',
    'CATALOGO_VERSION' => 'v2.1'
```

After deploying, please invoke the following in order to reindex from the latest release of the Catalogo, and rebuild the partials:
```
cap [STAGE] deploy:reindex
```
