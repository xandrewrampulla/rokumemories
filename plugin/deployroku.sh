#!/bin/bash

ROKU_IP=192.168.68.102
ARCHIVE=${1:-build/roku.zip}

if [ ! -f "$ARCHIVE" ]; then
    echo "Package not found: $ARCHIVE" >&2
    exit 1
fi

if [ -s .rokupassword ]; then
    ROKU_PASS=$(cat .rokupassword)
else
    read -s -p "Enter Roku developer password: " ROKU_PASS
    echo
fi

echo "Installing..."
curl --digest \
     -u "rokudev:$ROKU_PASS" \
     -c /tmp/cookies.txt \
     "http://$ROKU_IP/" \
     > /dev/null

# Upload using the saved cookies
curl --digest \
     -u "rokudev:$ROKU_PASS" \
     -b /tmp/cookies.txt \
     -c /tmp/cookies.txt \
     -F "mysubmit=Install" \
     -F "archive=@${ARCHIVE};type=application/zip" \
     --silent --show-error \
     -o /dev/null \
     "http://$ROKU_IP/plugin_install"

echo "Done"

