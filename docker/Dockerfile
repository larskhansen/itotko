FROM php:7.4-apache as builder

WORKDIR /var/www

# We need the gd and zip for composer install
RUN apt-get update && \
    apt-get install -y --no-install-recommends sass git libfreetype6-dev \
    libjpeg62-turbo-dev libpng-dev zlib1g-dev zip unzip libzip-dev

# GD is required for Drupal 8
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Zip is for composer.
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip

# Setup composer for installing the site.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# We need the recipe for the site.
ADD composer.json .
ADD composer.lock .
ADD config/ ./config/

# Instailling it.
RUN composer install

# Setting up the theme. Installing the sass bootstrap repo
# and building the scss files.
RUN cd /var/www/web/themes/custom/itotko_theme \
    && git clone https://github.com/twbs/bootstrap-sass.git bootstrap \
    && mkdir css \
    && sass scss/style.scss css/style.css

# Now to the actual docker image
FROM php:7.4-apache

# No need to build it again, just copy it.
COPY --from=builder /var/www /var/www

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


# Installing gd and memcached.
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        mariadb-client \
        libmemcached-dev \
        zlib1g-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql \
    && pecl install memcached-3.1.5 \
    && docker-php-ext-enable memcached

# Changing the apache_document_root to remove the unused html folder.
RUN sed -i "s|/var/www/html|$APACHE_DOCUMENT_ROOT|" \
    /etc/apache2/sites-available/000-default.conf

# The settings.php file does not have the sensitive db settings.
ADD docker/settings.php /var/www/web/sites/default/settings.php

# The startup script, this also starts the apache_foreground script.
ADD docker/start-itotko /usr/local/bin/

# Set the working directory.
WORKDIR /var/www

# Gentlemen, start your engines...
CMD ["start-itotko"]
