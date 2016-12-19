[![Stories in Ready](https://badge.waffle.io/pulibrary/cicognara-rails.png?label=ready&title=Ready)](https://waffle.io/pulibrary/cicognara-rails)

# cicognara-rails
Rails app for managing metadata for the Digital Cicogara Library

# To Run:
```
# this runs solr and indexes the fixture data
rake server
```

# To index the full Catalogo:
```
TEIPATH=/path/to/Catalogo_Cicognara.tei.xml MARCPATH=/path/to/cicognara.mrx.xml rake tei:index
```

# To create html partials of full Catalogo:
```
# creates partials at default path app/views/pages/catalogo
TEIPATH=/path/to/cicognara.tei.xml rake tei:partials
```
A non-default partials path can be specified:
```
 PARTIALSPATH=app/views/pages/NON-DEFAULT-FOLDER rake tei:partials
```

# To create the initial admin user, create a user account and then make the last user an admin:
```
rake set_admin_role
```
You can also specify an email address to make a particular user an amdin:
```
EMAIL=user@example.org rake set_admin_role
```

# Deploying:
When deploying, make sure the desired cicognara-catalogo (MARC and TEI) release is specified:
```
# config/deploy.rb`
set :default_env,
    'MARCPATH' => 'public/cicognara.mrx.xml',
    'TEIPATH' => 'public/catalogo.tei.xml',
    'CATALOGO_VERSION' => 'v1.2'
```
