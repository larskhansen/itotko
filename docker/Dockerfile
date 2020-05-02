FROM php:7.4-apache
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

COPY --chown=www-data:www-data config /var/www/config
COPY --chown=www-data:www-data vendor /var/www/vendor
COPY --chown=www-data:www-data web /var/www/web
COPY --chown=www-data:www-data composer.json /var/www/
COPY --chown=www-data:www-data composer.lock /var/www/

RUN sed -i "s|/var/www/html|/var/www|" /etc/apache2/sites-available/000-default.conf

COPY docker/run_startup.sh /

WORKDIR /var/www
