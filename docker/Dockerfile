FROM php:7.4-apache

ENV USERNAME=username \
    PASSWORD=password \
    HOST=host \
    DB=db

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

COPY --chown=www-data:www-data config /var/www/config
COPY --chown=www-data:www-data vendor /var/www/vendor
COPY --chown=www-data:www-data web /var/www/web
COPY --chown=www-data:www-data composer.json /var/www/
COPY --chown=www-data:www-data composer.lock /var/www/

RUN sed -i "s|/var/www/html|/var/www/web|" /etc/apache2/sites-available/000-default.conf

COPY docker/settings.php /var/www/web/sites/default/settings.php

COPY docker/setup-itotko /usr/local/bin/

WORKDIR /var/www

CMD ["setup-itotko"]
