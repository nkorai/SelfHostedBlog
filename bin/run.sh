#!/bin/bash

export DOMAIN_NAME="" # This should be in the format "example.org" or "www.example.org" based on your redirect rules
export EMAIL_ADDRESS="" # This is used by LetsEncrypt for recovery purposes and not used anywhere else in the solution

if [ -z "$DOMAIN_NAME" ] || [ -z "$EMAIL_ADDRESS" ]
then
  echo "### Required environment variables not set. DOMAIN_NAME=${DOMAIN_NAME} EMAIL_ADDRESS=${EMAIL_ADDRESS}. Exiting.";
  exit 1
fi

echo "### Using the environment variables: DOMAIN_NAME=${DOMAIN_NAME} EMAIL_ADDRESS=${EMAIL_ADDRESS}"

echo "### Creating build folder structure"
mkdir -p ./build
mkdir -p ./build/tmp

###
# nginx setup
###
if [ -d "./build/nginx" ]
then
  echo "### Found nginx assets in build folder, skipping setup"
else
  echo "### nginx setup missing, seeding with a temporary container to ensure real nginx container launch later succeeds with volume mounts"
  # https://github.com/nginxinc/docker-nginx/issues/360
  docker container create --name tmp_nginx nginx
  mkdir ./build/nginx/
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

echo "### Copying over new nginx configuration to intermediate location"
cp ./bin/nginx/new_default.conf ./build/tmp/new_default.conf

echo "### Injecting DOMAIN_NAME into new nginx configuration"
sed -i "s|DOMAIN_NAME|${DOMAIN_NAME}|g" ./build/tmp/new_default.conf

echo "### Copying over new nginx configuration to final locations to follow convention"
cp ./build/tmp/new_default.conf ./build/nginx/conf.d/sites-available/new_default.conf
cp ./build/tmp/new_default.conf ./build/nginx/conf.d/sites-enabled/new_default.conf

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
  mkdir ./build/ddns
  cp ./bin/ddns/config.json ./build/ddns
fi

echo "### Inject DDNS password and domain name into DDNS configuration"
DDNS_PASSWORD=$(<bin/secrets/ddns_secret.txt)
sed -i "s|DDNS_PASSWORD|${DDNS_PASSWORD}|g" ./build/ddns/config.json
sed -i "s|DOMAIN_NAME|${DOMAIN_NAME}|g" ./build/ddns/config.json

echo "### Bringing up all docker compose services"
docker-compose up -d