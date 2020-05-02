#!/usr/bin/env bash

cd /var/www || return

# Insert the database settings into settings.php.
vendor/bin/drupal dba --password=$PASSWORD --driver=mysql --host=$HOST --database=$DB \
--username=$USERNAME --port=3306 --default -n
