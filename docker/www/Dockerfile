ARG BRANCH=master

FROM php:7.4-cli as builder

ARG BRANCH

ENV BRANCH=${BRANCH}

WORKDIR /var/lib/jenkins

RUN apt-get update && \
    apt-get -q -y install php-intl php-soap git ssh && \
   	rm -rf /var/lib/apt/lists/* && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    apt-get autoremove -y

RUN mkdir www
ADD composer.lock ./www/
ADD composer.json ./www/
ADD config/ ./www/config/
ADD docker/www/script/change_branch.sh ./www
RUN chown -R jenkins:jenkins /var/lib/jenkins/www

WORKDIR /var/www

RUN composer update --no-dev --with-dependencies

FROM php:7.4-apache

ENV APACHE_ROOT=/var/www/web \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_SERVER_NAME=itotko \
    MEMCACHED_SERVER=memcached \
    URL_PATH=app \
    MARIA_DB=to_be_replaced \
    MARIA_USER=to_be_replaced \
    MARIA_PASSWORD=to_be_replaced \
    MARIA_HOST=to_be_replaced

RUN apt-get update && \
	apt-get -q -y install php-intl php-soap postgresql-client && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get autoremove -y && \
	a2enmod rewrite headers cache_disk

WORKDIR /var/www
COPY --from=builder /var/www /var/www

RUN rm -rf change_branch.sh .editorconfig .gitattributes html

ADD docker/www/conf/apache2.conf /etc/apache2/
ADD docker/www/conf/fqdn.conf /etc/apache2/conf-available/
ADD docker/www/conf/settings.php /var/www/web/sites/default/
ADD docker/www/script/run_* /
#ADD --chown=www-data:www-data ["files.tar.gz", "/tmp/"]

RUN mkdir /var/www/web/sites/default/files
RUN chown -R www-data:www-data /var/www
RUN chmod -R 775 /var/www/web/sites/default/files
