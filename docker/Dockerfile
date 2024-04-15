FROM composer:2

FROM php:8.1-apache as builder

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www

# We need the gd and zip for composer install
RUN apt-get update && \
    apt-get install -y --no-install-recommends git libfreetype6-dev \
    libjpeg62-turbo-dev libpng-dev zlib1g-dev zip unzip libzip-dev

# GD is required for Drupal 8
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Zip is for composer.
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip

RUN chown -Rf www-data:www-data /var/www
USER www-data

# We need the recipe for the site.
ADD composer.json .
ADD config/ ./config/

# Instailling it.
RUN composer update --no-cache

# Building the style sheet and installing plugins for bootstrap5.
FROM node:17.9 as script-builder

COPY --from=builder /var/www /var/www

WORKDIR /var/www/web/themes

RUN npm --prefix contrib/bootstrap5 install && \
    npm install -g sass && \
    sass custom/itotko_theme/scss/style.scss custom/itotko_theme/css/style.css

# Now to the actual docker image
FROM php:8.1-apache

# Enable the production settings of the  php ini.
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# No need to build it again, just copy it.
COPY --chown=www-data:www-data --from=script-builder /var/www /var/www

# Environment used for the database.
ENV USERNAME=username \
    PASSWORD=password \
    HOST=hostname \
    DB=dbname \
    PORT=3306 \
    DOMAINNAME=itotko.dk \
    WWWDOMAINNAME=www.itotko.dk \
    APACHE_DOCUMENT_ROOT=/var/www/web \
    MEMCACHED_SERVER=192.168.1.50 \
    STARTUP=drupal


# Installing gd, memcached, pdo_mysql, zip and opcache.
RUN apt-get update \
    && apt-get install -y \
       libfreetype6-dev \
       libjpeg62-turbo-dev \
       libpng-dev \
       mariadb-client \
       libevent-dev \
       libmemcached-dev \
       zlib1g-dev \
       libzip-dev \
       libapache2-mod-rpaf \
       libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql zip opcache \
    && pecl install memcached-3.2.0 \
    && docker-php-ext-enable memcached \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y

# Setup Opcache
RUN { \
		echo 'opcache.enable=1'; \
		echo 'opcache.memory_consumption=192'; \
		echo 'opcache.interned_strings_buffer=16'; \
		echo 'opcache.max_accelerated_files=10000'; \
		echo 'opcache.revalidate_freq=0'; \
		echo 'opcache.validate_timestamp=1'; \
		echo 'opcache.max_wasted_percentage=10'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Setup Apache remoteip
RUN { \ 
		echo 'RemoteIPHeader CF-Connecting-IP'; \
		echo 'RemoteIPInternalProxy 172.17.0.1'; \
		echo 'RemoteIPTrustedProxy 172.17.0.0/20'; \
		echo 'RemoteIPHeader X-Real-IP'; \
	} > /etc/apache2/mods-available/remoteip.conf

# Changing the apache_document_root to remove the unused html folder.
RUN sed -i "s|/var/www/html|$APACHE_DOCUMENT_ROOT|" /etc/apache2/sites-available/000-default.conf \
    sed -i "s|*:80>|*:8080>|" /etc/apache2/sites-available/000-default.conf \
    sed -i '1Listen 8080' /etc/apache2/ports.conf
    && a2enmod rewrite remoteip \
    && rm -rf /var/www/html \
    && chown -Rf www-data:www-data /var/www/web

# The settings.php file does not and MUST NOT have the sensitive db settings.
# This will be filled in via Environment variables in the startup script.
ADD --chown=www-data:www-data docker/settings.php /var/www/web/sites/default/settings.php

USER www-data

# Set the working directory.
WORKDIR /var/www
