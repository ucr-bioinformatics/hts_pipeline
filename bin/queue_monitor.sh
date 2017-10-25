#!/bin/bash

if [[ $# -lt 2  ]]; then
    echo "Usage: queue_monitor.sh <queue_user> <alert_email>"
    exit 1
fi

COMMAND="squeue -u $1"

while [ $($COMMAND | wc -l) -gt 1 ]; do
    $COMMAND
    sleep 30
done

if [[ ! -z "$2" ]]; then
    echo "Sending email to $2"
    /usr/sbin/sendmail -t << EOF
To: $2
From: no-reply@biocluster.ucr.edu
Subject: Queue Completed

The queue for user $1 is now empty.

EOF
    exit $?
fi

