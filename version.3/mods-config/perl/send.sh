#!/bin/bash

MAILFILE="/tmp/mailgun.queue"

while :
do
        echo "Check for scripts to run."
        if [ -s "$MAILFILE" ]
        then
                echo "$MAILFILE is exists and is not empty.\n Run script..."
                bash $MAILFILE
                echo "Empty the script file."
                > $MAILFILE
        else
                echo "Nothing to run."
        fi
        echo "Wait for 5 minutes until the next run."
        sleep 5m
done
