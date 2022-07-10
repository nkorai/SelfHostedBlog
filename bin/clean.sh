#!/bin/bash
docker ps -all -q --filter "name=rproxy" | grep -q . && docker stop rproxy && docker rm -fv rproxy
docker ps -all -q --filter "name=ddns-updater" | grep -q . && docker stop ddns-updater && docker rm -fv ddns-updater
rm -rf build