FROM php:7.4-apache as builder

WORKDIR /var/www

RUN echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

RUN apt-get update && \
    apt-get install -y --no-install-recommends git libfreetype6-dev libjpeg62-turbo-dev libpng-dev zlib1g-dev zip unzip libzip-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

ADD composer.json .
ADD composer.lock .
ADD config/ .

RUN composer install

FROM php:7.4-apache

COPY --from=builder /var/www /var/www

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

RUN sed -i "s|/var/www/html|/var/www/web|" /etc/apache2/sites-available/000-default.conf

COPY docker/settings.php /var/www/web/sites/default/settings.php

COPY docker/setup-itotko /usr/local/bin/

WORKDIR /var/www

CMD ["setup-itotko"]
