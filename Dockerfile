#FROM didstopia/base:nodejs-12-steamcmd-ubuntu-18.04
#FROM steamcmd/steamcmd:latest
#FROM ghcr.io/goover/steamcmd:ubuntu
FROM amd64/debian:stable-20230109-slim

#LABEL maintainer="Didstopia <support@didstopia.com>"
LABEL maintainer="Deltaman <noc@as202418.net>"

# Fixes apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN dpkg --add-architecture i386
#    echo steam steam/question select "I AGREE" | debconf-set-selections && \
#    echo steam steam/license note '' | debconf-set-selections && \
RUN    apt update && \
       apt install -y --no-install-recommends \
        curl \
#       steamcmd \
#        lib32gcc1 \
        lib32gcc-s1=10.2.1-6 \
        libstdc++6 \
#        libsdl2-2.0-0:i386 \
        libc6-i386 \
        libcurl4 \
        ca-certificates=20210119
#        libcurl4-gnutls-dev:i386 \
#        libcurl4-openssl-dev:i386

RUN ln -sf /usr/games/steamcmd /usr/local/bin/steamcmd && \
    ls -la /usr/lib/*/libcurl.so* && \
#    ln -sf /usr/lib/i386-linux-gnu/libcurl.so.4 /usr/lib/i386-linux-gnu/libcurl.so && \
#    ln -sf /usr/lib/i386-linux-gnu/libcurl.so.4 /usr/lib/i386-linux-gnu/libcurl.so.3 && \
    cd ~ && \
    ln -s /usr/games/steamcmd steamcmd && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/dumps \
        /tmp/* \
        /var/cache/apt

# Create and set the steamcmd folder as a volume
RUN mkdir -p /steamcmd/stationeers

# Add the steamcmd installation script
ADD install.txt /app/install.txt

# Copy the startup script
ADD start_stationeers.sh /app/start.sh

# Set the current working directory
WORKDIR /

## More info about the new syntax for running the server from the developer:
# https://github.com/rocket2guns/StationeersDedicatedServerGuide

# Setup default environment variables for the server
ENV STATIONEERS_SERVER_STARTUP_ARGUMENTS "-loadlatest "Mars" mars -settings StartLocalHost true AutoSave true ServerVisible true ServerMaxPlayers 20 UPNPEnabled false"
#ENV STATIONEERS_SERVER_NAME "Drebbel Server"
ENV STATIONEERS_WORLD_NAME "Mars"
ENV STATIONEERS_WORLD_TYPE "mars"
ENV STATIONEERS_SERVER_SAVE_INTERVAL "300"
ENV STATIONEERS_GAME_PORT "27500"
#ENV STATIONEERS_QUERY_PORT "27501"
#ENV STATIONEERS_SERVER_PASSWORD ""
#ENV STATIONEERS_ADMIN_PASSWORD ""

# Install steamcmd and verify that it is working
RUN mkdir -p /steamcmd && \
    curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
    | tar -v -C /steamcmd -zx && \
    chmod +x /steamcmd/steamcmd.sh && \
    /steamcmd/steamcmd.sh +login anonymous +quit

# Run as a non-root user by default
ENV PGID 1000
ENV PUID 1000

# Expose necessary ports
EXPOSE 27500/tcp
EXPOSE 27500/udp
EXPOSE 27501/udp

# Define directories to take ownership of
ENV CHOWN_DIRS "/app,/steamcmd"

# Expose the volumes
# VOLUME ["/steamcmd/stationeers"]

# Start the server
CMD [ "bash", "/app/start.sh"]
