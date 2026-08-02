#!/bin/bash

ROKU_IP=192.168.68.102
ROKU_PASS=123456

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
     -F "archive=@build/roku.zip;type=application/zip" \
     --silent --show-error \
     -o /dev/null \
     "http://$ROKU_IP/plugin_install"

echo "Done"

