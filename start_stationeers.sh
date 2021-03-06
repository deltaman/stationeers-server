#!/usr/bin/env bash

# Enable debugging
#set -x

# Setup error handling
set -e
set -o pipefail

# Print the user we're currently running as
echo "Running as user: $(whoami)"

# Define the exit handler
exit_handler()
{
	echo ""
	echo "Waiting for server to shutdown.."
	echo ""
	kill -SIGINT "$child"
	sleep 5

	echo ""
	echo "Terminating.."
	echo ""
	exit
}

# Trap specific signals and forward to the exit handler
trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

# Install/update steamcmd
echo ""
echo "Installing/updating steamcmd.."
echo ""
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# Check that Stationeers exists in the first place
if [ ! -f "/steamcmd/stationeers/rocketstation_DedicatedServer.x86_64" ]; then
	# Install Stationeers from install.txt
	echo ""
	echo "Installing Stationeers.."
	echo ""
	bash /steamcmd/steamcmd.sh +runscript /app/install.txt
else
	# Install Stationeers from install.txt
	echo ""
	echo "Updating Stationeers.."
	echo ""
	bash /steamcmd/steamcmd.sh +runscript /app/install.txt
fi

# Remove extra whitespace from startup command
STATIONEERS_STARTUP_COMMAND=$(echo "$STATIONEERS_SERVER_STARTUP_ARGUMENTS" | tr -s " ")

# Set the game port
if [ ! -z ${STATIONEERS_GAME_PORT+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -gameport=${STATIONEERS_GAME_PORT}"
fi

# Set the query/update port
if [ ! -z ${STATIONEERS_QUERY_PORT+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -updateport=${STATIONEERS_QUERY_PORT}"
fi

# Set the world name
if [ ! -z ${STATIONEERS_WORLD_NAME+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -worldname=${STATIONEERS_WORLD_NAME} -loadworld=${STATIONEERS_WORLD_NAME}"
fi

# Set the world type
if [ ! -z ${STATIONEERS_WORLD_TYPE+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -worldtype=${STATIONEERS_WORLD_TYPE}"
fi

# Set the auto-save interval
if [ ! -z ${STATIONEERS_SERVER_SAVE_INTERVAL+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -autosaveinterval=${STATIONEERS_SERVER_SAVE_INTERVAL}"
fi

# Set the server name
if [ ! -z ${STATIONEERS_SERVER_NAME+x} ]; then
	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -servername=\"${STATIONEERS_SERVER_NAME}\""
fi

## Set the server password
#if [ ! -z ${STATIONEERS_SERVER_PASSWORD+x} ]; then
#	STATIONEERS_STARTUP_COMMAND="${STATIONEERS_STARTUP_COMMAND} -password=${STATIONEERS_SERVER_PASSWORD}"
#fi

# Set the working directory
cd /steamcmd/stationeers || exit

# Run the server
echo ""
echo "Starting Stationeers with arguments: ${STATIONEERS_STARTUP_COMMAND}"
echo ""
./rocketstation_DedicatedServer.x86_64 \
  -logfile /steamcmd/stationeers/dedi_logging.txt \
  ${STATIONEERS_STARTUP_COMMAND} \
  2>&1 &
# ./rocketstation_DedicatedServer.x86_64 \
# 	${STATIONEERS_SERVER_STARTUP_ARGUMENTS} \
# 	-gameport=${STATIONEERS_GAME_PORT} \
# 	-updateport=${STATIONEERS_QUERY_PORT} \
# 	-worldname=${STATIONEERS_WORLD_NAME} \
# 	-loadworld=${STATIONEERS_WORLD_NAME} \
# 	-autosaveinterval=${STATIONEERS_SERVER_SAVE_INTERVAL} \
# 	-servername "${STATIONEERS_SERVER_NAME}" \
# 	2>&1 &

child=$!
wait "$child"
