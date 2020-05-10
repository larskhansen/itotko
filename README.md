# Repository for itotko.dk

![Itotko-master](![Itotko-master](https://github.com/larskhansen/itotko/workflows/Itotko-master/badge.svg?branch=master&event=push))

This project is for the Drupal 8 website, itotko.dk. The site is running on a Docker Swarm setup with 3 Raspberry Pi's. You can find the docker images on [my docker hub repository](https://hub.docker.com/repository/docker/larskhansen/itotko)

## Docker Swarm Usage

You need to start up the service on the master:
```
docker service create \
  --mode replicated \
  --replicas 0 \
  --name itotko-dk \
  --network yournetwork-name \
  --endpoint-mode dnsrr \
  larskhansen/itotko-dk
```

> Note: This is a great website if you want to learn more about [Docker Swarm and HA-Proxy](https://www.haproxy.com/blog/haproxy-on-docker-swarm-load-balancing-and-dns-service-discovery/).
