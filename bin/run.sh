#!/bin/bash

# Start as fresh as possible
eval "./bin/clean.sh"

# Hack to get around bind mounting nginx in the compose file
# https://github.com/nginxinc/docker-nginx/issues/360
docker container create --name tmp_nginx nginx
mkdir -p ./build/nginx/conf/
mkdir -p ./build/ssl/private/
docker cp tmp_nginx:/etc/nginx/ ./build/nginx/conf/
docker cp tmp_nginx:/etc/ssl/private ./build/ssl/private/
docker container rm tmp_nginx

# Create nginx folders
mkdir -p ./build/nginx/conf/nginx/conf.d/sites-available
mkdir -p ./build/nginx/conf/nginx/conf.d/sites-enabled

# Copy over new nginx configuration
cp bin/nginx/new_default.conf ./build/nginx/conf/nginx/conf.d/sites-available
cp bin/nginx/new_default.conf ./build/nginx/conf/nginx/conf.d/sites-enabled
rm ./build/nginx/conf/nginx/conf.d/default.conf

# Point nginx configuration to our custom new default configuration
sed -i 's|include /etc/nginx/conf.d/\*.conf;|include /etc/nginx/conf.d/sites-enabled/\*.conf;|g' ./build/nginx/conf/nginx/nginx.conf

# Create DDNS folder and copy over our config
mkdir -p ./build/ddns
cp bin/ddns/config.json ./build/ddns

# Inject DDNS password into DDNS configuration
ddns_password=`secrets/namecheap.txt`
sed -i 's|"password": "password",|"password": "${ddns_password}",|g' ./build/ddns/config.json


# Ready to bring up our services
# docker-compose up