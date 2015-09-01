#!/bin/bash

MAILFILE="/tmp/mailgun.queue"

if [ -s "$MAILFILE" ]
then
        echo "$MAILFILE is exists and is not empty.\n Run script..."
        bash $MAILFILE
        echo "Empty the script file."
        > $MAILFILE
fi
