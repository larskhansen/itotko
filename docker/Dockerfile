FROM php:7.4-apache
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

COPY config /var/www/
COPY vendor /var/www/
COPY web /var/www/
COPY composer.json /var/www/
COPY composer.lock /var/www/

WORKDIR /var/www
