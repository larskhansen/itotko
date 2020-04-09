#!/usr/bin/env bash

cd /tmp || return
rm -rf files.tar.gz

SETTINGS=/var/www/web/sites/default/settings.php

# Apache root path
sed -i "s|/var/www/html|$APACHE_ROOT|" /etc/apache2/sites-available/000-default.conf

# Solr server url
sed -i "s/localhost/$SOLR_SERVER/" /var/www/config/sync/search_api.server.fl_solr_server.yml

# Memcached server url
sed -i "s/@MEMCACHED_SERVER@/$MEMCACHED_SERVER/" $SETTINGS

# trusted_host_patterns
sed -i "s/@DOMAIN@/$APACHE_SERVER_NAME/" $SETTINGS

cd /var/www || return
# Insert the database settings into settings.php.
vendor/bin/drupal dba --password=$POSTGRES_PASSWORD --driver=pgsql --host=$POSTGRES_HOST --database=$POSTGRES_DB \
--username=$POSTGRES_USER --port=5432 --default -n