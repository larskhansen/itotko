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

WORKDIR /app

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
COPY --from=builder /app/web/themes/custom/itotko_theme/package*.json ./

RUN npm ci

# Copy full theme source
COPY --from=builder /app/web/themes/custom/itotko_theme ./

# Build assets (SCSS/JS → css/)
RUN npm run build

############################################################
# 3. RUNTIME STAGE - Apache + PHP + Drupal 11
############################################################
FROM php:8.3-apache AS runtime

WORKDIR /var/www/html

############################################################
# System dependencies for Drupal AND Apache: run on port 8080
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
    && a2enmod rewrite \
    && sed -i 's/80/8080/g' /etc/apache2/ports.conf

COPY docker/drupal.conf /etc/apache2/sites-available/000-default.conf

############################################################
# Copy Drupal codebase
############################################################
COPY --from=builder /app /var/www/html

############################################################
# Copy built theme assets
############################################################
COPY --from=theme-builder /theme/css /var/www/html/web/themes/custom/itotko_theme/css

############################################################
# Copy settings.php file for Drupal setup
############################################################
COPY --chown=www-data:www-data docker/settings.php /var/www/html/web/sites/default/settings.php

############################################################
# Permissions (CRITICAL for Drupal)
############################################################
RUN chown -R www-data:www-data /var/www/html \
 && mkdir -p /var/www/html/web/sites/default/files \
 && chown -R www-data:www-data /var/www/html/web/sites/default/files \
 && chmod -R 777 /var/www/html/web/sites/default/files

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
