[![Stories in Ready](https://badge.waffle.io/pulibrary/cicognara-rails.png?label=ready&title=Ready)](https://waffle.io/pulibrary/cicognara-rails)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/cicognara-rails/badge.svg)](https://coveralls.io/github/pulibrary/cicognara-rails)

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
TEIPATH=/path/to/cicognara-catalogo/Catalogo_Cicognara.tei.xml rake tei:index
```
