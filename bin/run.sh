#!/bin/bash

# Start as fresh as possible
eval "./bin/clean.sh"

# Hack to get around bind mounting nginx in the compose file
# https://github.com/nginxinc/docker-nginx/issues/360
docker container create --name tmp_nginx nginx
mkdir -p ./nginx/conf/
mkdir -p ./ssl/private/
docker cp tmp_nginx:/etc/nginx/ ./nginx/conf/
docker cp tmp_nginx:/etc/ssl/private ./ssl/private/
docker container rm tmp_nginx

# Create nginx folders
mkdir -p ./nginx/conf/nginx/conf.d/sites-available
mkdir -p ./nginx/conf/nginx/conf.d/sites-enabled

# Copy over new nginx configuration
# TODO: overkill and symlink these in the future
cp bin/nginx/new_default.conf ./nginx/conf/nginx/conf.d/sites-available
cp bin/nginx/new_default.conf ./nginx/conf/nginx/conf.d/sites-enabled
rm ./nginx/conf/nginx/conf.d/default.conf

# Point nginx configuration to our custom new default configuration
sed -i 's|include /etc/nginx/conf.d/\*.conf;|include /etc/nginx/conf.d/sites-enabled/\*.conf;|g' ./nginx/conf/nginx/nginx.conf

# Ready to bring up our services
docker-compose up