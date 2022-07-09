#!/bin/bash
docker ps -all -q --filter "name=rproxy" | grep -q . && docker stop rproxy && docker rm -fv rproxy
rm -rf build
ls