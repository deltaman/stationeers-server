#!/bin/bash

# Build changes (if necessary)
./docker_build.sh

# Run a container
docker run -p 0.0.0.0:27500:27500/tcp -p 0.0.0.0:27500:27500/udp -p 0.0.0.0:27016:27016/udp -v "$(pwd)/stationeers_data:/steamcmd/stationeers" --name stationeers-server -it --rm deltaman01/stationeers-server:latest
