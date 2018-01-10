#!/bin/bash -l
if [ $# -lt 1 ]; then
    echo "$(basename "$0") <targetUsername>"
    exit 1
fi
nohup queue_monitor.sh $1 wshia002@ucr.edu &>> ~/logs/nohup.log &
