#!/bin/bash

export DOMAIN_NAME="nkorai.com" # This should be in the format "example.org" or "www.example.org" based on your redirect rules
export EMAIL_ADDRESS="nausherwan.korai@gmail.com" # This is used by LetsEncrypt for recovery purposes and not used anywhere else in the solution

# This is the directory where you want your ghost content to live. This directory will be backed up to AWS S3 in the future
# I chose a folder in the root of this repo, i.e. where the docker-compose.yaml file is located. I named the directory "ghost_content"
export GHOST_CONTENT_DIRECTORY="/ghost_content"

if [ -z "$DOMAIN_NAME" ] || [ -z "$EMAIL_ADDRESS" ] || [ -z "$GHOST_CONTENT_DIRECTORY" ]
then
  echo "### Required environment variables not set. DOMAIN_NAME=${DOMAIN_NAME} EMAIL_ADDRESS=${EMAIL_ADDRESS} GHOST_CONTENT_DIRECTORY=${GHOST_CONTENT_DIRECTORY}git . Exiting.";
  exit 1
fi

echo "### Using the environment variables: DOMAIN_NAME=${DOMAIN_NAME} EMAIL_ADDRESS=${EMAIL_ADDRESS} GHOST_CONTENT_DIRECTORY=${GHOST_CONTENT_DIRECTORY}"

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

echo "### Grant SSL folder access to everyone"
chmod ugo+rwx ./build/ssl/private

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

echo "### Injecting AWS Access Key ID and AWS Secret Access Key into env variables. This can only be accessed by containers that you explicitly pass them on to."
export AWS_ACCESS_KEY_ID=$(<bin/secrets/aws_access_key_id.txt)
export AWS_SECRET_ACCESS_KEY=$(<bin/secrets/aws_secret_access_key.txt)

echo "### Injecting Mailgun credentials into Ghost config.production.json"
if [ -d "./build/ghost" ];
then
  echo "### Found dynamic Ghost assets, skipping setup"
else
  echo "### Creating Ghost folder and copying over our config.production.json"
  mkdir ./build/ghost
  cp ./bin/ghost/config.production.json ./build/ghost
fi

MAILGUN_USER=$(<bin/secrets/mailgun_user.txt)
MAILGUN_PASSWORD=$(<bin/secrets/mailgun_password.txt)
sed -i "s|MAILGUN_USER|${MAILGUN_USER}|g" ./build/ghost/config.production.json
sed -i "s|MAILGUN_PASSWORD|${MAILGUN_PASSWORD}|g" ./build/ghost/config.production.json

echo "### Bringing up all docker compose services"
docker-compose up -d