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

## Tagging a Release

To create a tagged release use the [steps in the RDSS handbook](https://github.com/pulibrary/rdss-handbook/blob/main/release_process.md)

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

## Deploying (alternative)
Another way to reindex after a deployment is to SSH to the machine and execute the following rake tasks. This is what we did in March/2022. Notice that we had to manually get the Getty files via cURL before running `getty:import` because download process fails intermittently (however, once the files are on disk the rake task will use them and complete successfully).

```
cd /opt/cicognara/current

# Get latest source data files
TEIPATH=public/cicognara.tei.xml MARCPATH=public/cicognara.mrx.xml bundle exec rake tei:catalogo:update

# Run TEI Index (about 5 minutes)
TEIPATH=public/cicognara.tei.xml MARCPATH=public/cicognara.mrx.xml bundle exec rake tei:index

# Regenerate the partials
TEIPATH=public/cicognara.tei.xml MARCPATH=public/cicognara.mrx.xml bundle exec rake tei:partials

# Run Getty import (1 hr)
# (get files via cURL because it requires retries)
cd tmp
curl -OL http://portal.getty.edu/resources/json_data/resourcedump_2022-01-26-part1.zip
curl -OL http://portal.getty.edu/resources/json_data/resourcedump_2022-01-26-part2.zip
curl -OL http://portal.getty.edu/resources/json_data/resourcedump_2022-01-26-part3.zip
curl -OL http://portal.getty.edu/resources/json_data/resourcedump_2022-01-26-part4.zip
cd ..

bundle exec rake getty:import
```

### Create a production admin user

If you need to make someone an admin on a production box, ensure they've logged in once, then run the `set_admin_role` task for their email address:

`EMAIL=user@example.org bundle exec rake set_admin_role`

### Updating Solr in production
To make changes to the Solr in production/staging you need to update the files in the [pul_solr](https://github.com/pulibrary/pul_solr) repository and deploy them. The basic steps are:

1. Update the [configuration file for Cicognara](https://github.com/pulibrary/pul_solr/tree/main/solr_configs/cicognara)
2. Deploy the changes, e.g. `cap solr8-staging deploy`.

You can see the list of Capistrano environments [here](https://github.com/pulibrary/pul_solr/tree/main/config/deploy)

The deploy will update the configuration for all Solr collections in the given environment, but it does not cause downtime. If you need to manually reload a configuration for a given Solr collection you can do it via the Solr Admin UI.

## Google OAuth integration
The environment values used for integration with Google Authentication (`GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`) are defined via the `console.cloud.google.com`. You can use this [page](https://console.cloud.google.com/apis/credentials/oauthclient/639448642333-klf2kb6d7ka0dl4ph1vp9prblulp9l7a.apps.googleusercontent.com?project=pulibrary-figgy-storage-1&supportedpurview=project) to reset the `Client ID` and `Client secret` values. If you don't have access to this page please contact Esmé.

## Data Sources

There are three main sources of information for this project:
1. Data from TEI files (~4700 records)
2. Data from MARC files (~4700 records)
3. Data from the Getty (~9600 records)

The process to index TEI and MARC files (i.e. `rake tei:index`) ingests the data into a single Solr collection, but it creates
separate documents for each source. For example there are two Solr documents for `alt_id:"dcl:nvx"`, one of these documents
(the one with `format:marc`) has the MARC data whereas the other one has the TEI data. Records from TEI (i.e. `-format:marc`)
are what is searched for when a user submits a search.

This part of the import process also creates records in the `Books` and `Entries` tables to represent some of this data.

There is another process that fetches and processes the data from the Getty (i.e. `rake getty:import`). This process downloads
files from Getty, unzips them into about 50,000 JSON files, and finds records that are associated with the "Cicognara Collection".
There are about 9,600 records that meet this criteria. For each one of them it process the `manifest_urls` indicated in the Getty
record and creates a `Version` record to store the metadata for each different manifest.

This part of the process is slow-ish since, for each record, it contacts each different institution indicated in the `manifest_url`
to fetch the data ([example 1](https://figgy.princeton.edu/concern/scanned_resources/b9aba758-ce0e-47ef-a2f0-8c1273c60829/manifest)
and [example 2](https://digi.ub.uni-heidelberg.de/diglit/iiif/passeri1770/manifest.json)). This data is saved in the `Version` table.
Notice that the data stored in the `Version` table is displayed to the user but it is not indexed in Solr.

Check out the following documents for additional information on the data and how it is modeled:
* [Cicognara Project Notes](https://docs.google.com/document/d/1uyH_RPJcpYwYPOC6wnH888YkTCz-VJiLg30HYhblOUs/edit#).
* [Cicognara use cases / architecture discussion](https://docs.google.com/document/d/1hpMqtwGgwhK-VwJHNXuklObNPwBfo_OzveUxhELIydU/edit)
* [Catalogo Cicognara Edge Cases](https://github.com/pulibrary/cicognara-rails/wiki#catalogo-cicognara-edge-cases)
