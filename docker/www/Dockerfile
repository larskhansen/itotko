ARG BRANCH=master

FROM docker-dscrum.dbc.dk/d8-php7-builder as builder

ARG BRANCH

ENV BRANCH=${BRANCH}

WORKDIR /var/lib/jenkins

RUN apt-get update && \
    apt-get -q -y install php-intl php-soap git ssh && \
   	rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y

RUN mkdir www
ADD composer.lock ./www/
ADD composer.json ./www/
ADD config/ ./www/config/
ADD docker/www/script/change_branch.sh ./www
RUN chown -R jenkins:jenkins /var/lib/jenkins/www

USER jenkins

WORKDIR /var/lib/jenkins/www

RUN composer update --no-dev --with-dependencies

FROM docker.dbc.dk/dbc-apache-php7

ENV APACHE_ROOT=/var/www/web \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_SERVER_NAME=itotko \
    MEMCACHED_SERVER=memcached \
    URL_PATH=app \
    MARIA_DB=filestore \
    MARIA_USER=filestore \
    MARIA_PASSWORD=filestore \
    MARIA_HOST=mariadb

RUN apt-get update && \
	apt-get -q -y install php-intl php-soap postgresql-client && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get autoremove -y && \
	a2enmod rewrite headers cache_disk

WORKDIR /var/www
COPY --from=builder /var/lib/jenkins/www /var/www

RUN rm -rf change_branch.sh .editorconfig .gitattributes html

ADD docker/www/conf/apache2.conf /etc/apache2/
ADD docker/www/conf/fqdn.conf /etc/apache2/conf-available/
ADD docker/www/conf/settings.php /var/www/web/sites/default/
ADD docker/www/script/run_* /
#ADD --chown=www-data:www-data ["files.tar.gz", "/tmp/"]

RUN mkdir /var/www/web/sites/default/files
RUN chown -R www-data:www-data /var/www
RUN chmod -R 775 /var/www/web/sites/default/files
