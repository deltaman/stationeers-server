#!/bin/bash

# Build changes (if necessary)
./docker_build.sh

# Run a container
docker run -p 0.0.0.0:27815:27815/tcp -p 0.0.0.0:27815:27815/udp -p 0.0.0.0:27816:27816/udp -v "$(pwd)/stationeers_data:/steamcmd/stationeers" --name stationeers-server -it --rm deltaman01/stationeers-server:latest
