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
bundle exec rake db:setup
```

Remember you'll need to run `bundle install` on an ongoing basis as dependencies are updated.


## Run tests

`RAILS_ENV=test bundle exec rake db:setup`
`bundle exec rake cico:test`
In a separate terminal: `bundle exec rspec`

## Development setup

### Quick start
   - `bundle exec rake cico:development:server`
     - This will run Solr/Index Example Records, launch a rails server, and seed
       some tei data.
   - Access at http://localhost:3000/
   - Log in once
   - Become an admin with `bundle exec rake set_admin_role`
     - You can also specify an email address to make a user an admin:
       `EMAIL=user@example.org bundle exec rake set_admin_role`

### Individual services

You may want to run solr separately from the rails server so it's easier to stop
/ start one or the other more quickly.

`bundle exec rake cico:development` will run the development solr server
`bin/rails s` will run the rails server
`bundle exec rake tei:index` and
`bundle exec rake tei:partials` will load the seed data

## Index/Generate Partials for full Catalogo:

1. Ensure development solr is running
2. `cd tmp`
3. `git clone git@github.com:pulibrary/cicognara-catalogo.git`
4. `cd ..`
5. `TEIPATH=tmp/cicognara-catalogo/catalogo.tei.xml MARCPATH=tmp/cicognara-catalogo/cicognara.mrx.xml bundle exec rake tei:index`
6. `TEIPATH=tmp/cicognara-catalogo/catalogo.tei.xml bundle exec rake tei:partials`

## Indexing Full Manifests from Getty

1. Ensure full Catalogo is indexed (see above)
2. `bundle exec rake getty:import`

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
