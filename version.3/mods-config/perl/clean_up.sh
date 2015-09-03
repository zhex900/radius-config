#!/bin/bash

# run cleanup.pl once a month
while :
do
        # run clean up
        echo "Run clean up at: " `date`
        perl /etc/freeradius/mods-config/perl/clean_up.pl

        # schedule for the next run.
        startTime=$(date +%s)
        endTime=$(date -d "next month" +%s)
        timeToWait=$(($endTime- $startTime))
        days=$(($timeToWait/86400))
        echo "Next clean up will in " $days " days"
        sleep $timeToWait
done
