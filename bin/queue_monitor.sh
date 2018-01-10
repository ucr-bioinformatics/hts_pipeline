#!/bin/bash

if [[ $# -lt 2  ]]; then
    echo "Usage: queue_monitor.sh <queue_user> <alert_email>"
    exit 1
fi

# For deamon mode only
#COMMAND="squeue -u $1"
#while [ $($| wc -l) -gt 1 ]; do
#    $COMMAND
#    sleep 30
#done

NUM_JOBS=$(squeue -u $1 --noheader | wc -l)
RUNNING_JOBS=$(squeue -t R -u $1 --noheader | wc -l)
PENDING_JOBS=$(squeue -t PD -u $1 --start -l)

if [[ ! -z "$2" && ${NUM_JOBS} -gt 0 ]]; then
    echo "Sending email to $2"
    /usr/sbin/sendmail -t << EOF
To: $2
From: no-reply@biocluster.ucr.edu
Subject: HTS Pipeline Status

Total number of jobs: $NUM_JOBS
Number of running jobs: $RUNNING_JOBS
Status of pending jobs:
$PENDING_JOBS

EOF
    exit $?
fi
