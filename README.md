[![Stories in Ready](https://badge.waffle.io/pulibrary/cicognara-rails.png?label=ready&title=Ready)](https://waffle.io/pulibrary/cicognara-rails)

# cicognara-rails
Rails app for managing metadata for the Digital Cicogara Library

# To Run:
```
rake blacklight:server
```

# To index sample data:
```
rake tei:index
```

Or checkout [cicognara-catalogo](https://github.com/pulibrary/cicognara-catalogo) and index the full
 Catalogo:
```
TEIPATH=/path/to/Catalogo_Cicognara.tei.xml MARCPATH=/path/to/cicognara.mrx.xml rake tei:index
```

# To create html partials with fixture data to app/views/pages/catalogo:
```
rake tei:partials

# teipath and partials path can be specified
TEIPATH=/path/to/cicognara.tei.xml PARTIALSPATH=app/views/pages/partial rake tei:partials
```

# To create the initial admin user, create a user account and then make the last user an admin:
```
rake set_admin_role
```

You can also specify an email address to make a particular user an amdin:
```
EMAIL=user@example.org rake set_admin_role
```
