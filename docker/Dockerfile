############################################################
# 1. COMPOSER STAGE - Install Drupal dependencies
############################################################
FROM composer:2 AS composer

FROM php:8.3-apache AS builder

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN apt-get update && \
    apt-get install -y --no-install-recommends git libfreetype6-dev \
    libjpeg62-turbo-dev libpng-dev zlib1g-dev zip unzip libzip-dev

# install PHP extensions (THIS FIXES IT)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install gd

# Zip is for composer.
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip

RUN chown -Rf www-data:www-data /var/www
USER www-data

# We need the recipe for the site.
ADD composer.json .
ADD config/ ./config/

# Installing it.
RUN composer update --no-cache

# Building the style sheet and installing plugins for bootstrap5.
FROM node:24 AS script-builder

COPY --from=builder /var/www /var/www

WORKDIR /var/www/html/web/custom/itotko_theme

RUN npm install

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
    && sed -i "s|\*:80>|\*:8080>|" /etc/apache2/sites-available/000-default.conf \
    && sed -i '/Listen 80/d' /etc/apache2/ports.conf \
    && sed -i '1 i\Listen 8080' /etc/apache2/ports.conf \
    && a2enmod rewrite remoteip \
    && rm -rf /var/www/html \
    && chown -Rf www-data:www-data /var/www/web

# The settings.php file does not and MUST NOT have the sensitive db settings.
# This will be filled in via Environment variables in the startup script.
ADD --chown=www-data:www-data docker/settings.php /var/www/web/sites/default/settings.php
=======
WORKDIR /app
>>>>>>> Stashed changes

COPY composer.json composer.lock ./

RUN composer install \
  --no-dev \
  --prefer-dist \
  --no-interaction \
  --optimize-autoloader


############################################################
# 2. NODE STAGE - Build Bootstrap theme assets
############################################################
FROM node:24 AS theme-builder

WORKDIR /theme

# Copy only package files first (better caching)
COPY web/themes/custom/itotko_theme/package*.json ./

RUN npm ci

# Copy full theme source
COPY web/themes/custom/itotko_theme ./

# Build assets (SCSS/JS → dist/)
RUN npm run build


############################################################
# 3. RUNTIME STAGE - Apache + PHP + Drupal 11
############################################################
FROM php:8.3-apache AS runtime

WORKDIR /var/www/html

############################################################
# System dependencies for Drupal
############################################################
RUN apt-get update && apt-get install -y \
    git unzip \
    libpng-dev libzip-dev \
    libicu-dev \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        zip \
        gd \
        intl \
    && a2enmod rewrite

############################################################
# Apache: run on port 8080
############################################################
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf

COPY docker/drupal.conf /etc/apache2/sites-available/000-default.conf

############################################################
# Copy Drupal codebase
############################################################
COPY --from=builder /app /var/www/html

############################################################
# Copy built theme assets
############################################################
COPY --from=theme-builder /theme/css /var/www/html/web/themes/custom/itoto_theme/css

############################################################
# Copy settings.php file for Drupal setup
############################################################
COPY --chown=www-data:www-data docker/settings.php /var/www/web/sites/default/settings.php

############################################################
# Permissions (CRITICAL for Drupal)
############################################################
RUN chown -R www-data:www-data /var/www/html \
 && mkdir -p /var/www/html/web/sites/default/files \
 && chown -R www-data:www-data /var/www/html/web/sites/default/files \
 && chmod -R 775 /var/www/html/web/sites/default/files

############################################################
# Runtime user
############################################################
USER www-data

############################################################
# Expose port
############################################################
EXPOSE 8080

############################################################
# Start Apache
############################################################
CMD ["apache2-foreground"]
