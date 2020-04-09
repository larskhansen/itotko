#!/usr/bin/env bash

cd /var/www || return

vendor/bin/drush updb -y

vendor/bin/drupal ci --directory=/var/www/config/sync

vendor/bin/drush sdel library_login.last_cron

vendor/bin/drush cron

vendor/bin/drush cr
