#!/bin/bash

###
# nginx setup
###
if [ -d "./build/nginx" ];
then
  echo "### Found nginx assets in build folder, skipping setup"
else
  echo "### nginx setup missing, seeding with a temporary container to ensure real nginx container launch later succeeds with volume mounts"
  # https://github.com/nginxinc/docker-nginx/issues/360
  docker container create --name tmp_nginx nginx
  mkdir -p ./build/nginx/
  docker cp tmp_nginx:/etc/nginx/ ./build/
  docker cp tmp_nginx:/etc/ssl/ ./build/
  docker container rm tmp_nginx

  echo "### Creating sites nginx folders"
  mkdir ./build/nginx/conf.d/sites-available
  mkdir ./build/nginx/conf.d/sites-enabled

  rm ./build/nginx/conf.d/default.conf

  ###
  # SSL configuration
  ###
  echo "### Copying over dummy placeholder certs into nginx as it fails to come up without them in place. These will later be replaced by actual certs via LetsEncrypt"
  cp ./bin/ssl/placeholder_fullchain.pem ./build/ssl/private/fullchain.pem
  cp ./bin/ssl/placeholder_privkey.pem ./build/ssl/private/privkey.pem
fi

echo "### Copying over new nginx configuration"
cp ./bin/nginx/new_default.conf ./build/nginx/conf.d/sites-available
cp ./bin/nginx/new_default.conf ./build/nginx/conf.d/sites-enabled

echo "### Pointing nginx default configuration to our custom new default configuration"
sed -i "s|include /etc/nginx/conf.d/\*.conf;|include /etc/nginx/conf.d/sites-enabled/\*.conf;|g" ./build/nginx/nginx.conf

###
# Distributed DNS
###
if [ -d "./build/ddns" ];
then
  echo "### Found dynamic DNS assets, skipping setup"
else
  echo "### Creating DDNS folder and copying over our config"
  mkdir -p ./build/ddns
  cp ./bin/ddns/config.json ./build/ddns
fi

echo "### Inject DDNS password into DDNS configuration"
ddns_password=$(<bin/secrets/ddns_secret.txt)
sed -i "s|ddns_password|${ddns_password}|g" ./build/ddns/config.json

echo "### Bringing up all docker compose services"
docker-compose up