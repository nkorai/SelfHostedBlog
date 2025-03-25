# Via https://github.com/pmsipilot/docker-compose-viz
docker run --rm -it --name dcv -v $(pwd):/input pmsipilot/docker-compose-viz render -m image docker-compose.yaml --no-volumes --force --output-file=docker-compose-no-volumes.png
docker run --rm -it --name dcv -v $(pwd):/input pmsipilot/docker-compose-viz render -m image docker-compose.yaml --force --output-file=docker-compose-volumes.png