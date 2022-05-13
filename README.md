# Repository for itotko.dk

![Itotko-master](https://github.com/larskhansen/itotko/workflows/Itotko-master/badge.svg?branch=master&event=push)

This project is for the Drupal 9 website, itotko.dk. The site is running on a Docker Swarm setup with 3 Raspberry Pi's. You can find the docker images on [my docker hub repository](https://hub.docker.com/repository/docker/larskhansen/itotko)

## Docker Swarm Usage (Not updated anymore)

You need to start up the service on the master (Change the variables with < and > ):
```
docker service create \
  --mode replicated \
  --replicas 0 \
  --name <your service name> \
  --network <your network name> \
  --endpoint-mode dnsrr \
  -e DB=<your dbname> -e USERNAME=<your dbusername> \
  -e PASSWORD=<your dbpassword> -e HOST=<your dbhost> -e PORT=<your dbport> \
  larskhansen/itotko-dk
```
The replicas needs to be increased when the the service has been created.
The environment variables are used for a connection to a mySQL/mariaDB database.

> Note: This is a great website if you want to learn more about [Docker Swarm and HA-Proxy](https://www.haproxy.com/blog/haproxy-on-docker-swarm-load-balancing-and-dns-service-discovery/).

## Lando Usage

Use the lando for local development:
```
# You need to be in the folder where the .lando.yml file is located.
lando start

# Run composer
lando composer update

# Get the database ready and write the settings.php file.
lando pre-import

# Import the database
lando db-import sqlfile.sql

# Update the system with the latest stuff
lando post-import

# Rebuild the stylesheet
lando rebuild-stylesheet
```
