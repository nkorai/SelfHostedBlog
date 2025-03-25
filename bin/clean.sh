#!/bin/bash
cd "$(dirname "$0")/.."

containers=(rproxy ddns-updater letsencrypt ghost selfhostedblog-s3_backup-1)

for c in "${containers[@]}"; do
    if docker ps -a --filter "name=$c" -q | grep -q .; then
        echo "🧨 Force removing container: $c"
        docker rm -f "$c"
    fi
done

echo "🧹 Removing build folder"
rm -rf build

