#!/bin/bash
docker ps -all -q --filter "name=rproxy" | grep -q . && docker stop rproxy
docker ps -all -q --filter "name=ddns-updater" | grep -q . && docker stop ddns-updater
docker ps -all -q --filter "name=letsencrypt" | grep -q . && docker stop letsencrypt
rm -rf build