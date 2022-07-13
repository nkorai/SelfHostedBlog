#!/bin/bash
docker ps -all -q --filter "name=rproxy" | grep -q . && docker stop rproxy && docker rm rproxy
docker ps -all -q --filter "name=ddns-updater" | grep -q . && docker stop ddns-updater && docker rm ddns-updater
docker ps -all -q --filter "name=letsencrypt" | grep -q . && docker stop letsencrypt && docker rm letsencrypt
rm -rf build