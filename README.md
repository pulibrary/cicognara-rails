# Cicognara

An application for indexing and displaying IIIF Manifests from multiple partners
in an effort to create a high quality digital version of Count Leopoldo Cicognara's private
book collection.

[![CircleCI](https://circleci.com/gh/pulibrary/cicognara-rails.svg?style=svg)](https://circleci.com/gh/pulibrary/cicognara-rails)
[![Coverage Status](https://coveralls.io/repos/pulibrary/cicognara-rails/badge.svg?branch=main&service=github)](https://coveralls.io/github/pulibrary/cicognara-rails?branch=main)


## Initial Setup

```sh
git clone https://github.com/pulibrary/cicognara-rails.git
cd cicognara-rails
bundle install
lando start
bundle exec rake db:setup
```

Remember you'll need to run `bundle install` on an ongoing basis as dependencies are updated.


## Run tests

1. `lando start`
1. `RAILS_ENV=test bundle exec rake db:setup`
3. In a separate terminal: `bundle exec rspec`

## Development setup

### Running development services together

Install Lando:

* [Lando on GitHub](https://github.com/lando/lando/releases)

1. `lando start`
2. `bundle exec rake cico:development:clean_and_seed`
3. `bin/rails s`

### Create a development admin user

`bin/rails c`
`> u = User.new`
`> u.email = me@example.com`
`> u.role = "admin"`

Look at `app/controllers/application_controller.rb` to see how this user is
always logged in on a development site. You can comment out the `current_user`
method there if you want to see a non-admin view.

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

### Create a production admin user

If you need to make someone an admin on a production box, ensure they've logged in once, then run the `set_admin_role` task for their email address:

`EMAIL=user@example.org bundle exec rake set_admin_role`
