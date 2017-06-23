#!/bin/bash

# Add hts tools to PATH
if [ ! -z $HTS_PIPELINE_HOME ]; then
    export PATH=$HTS_PIPELINE_HOME/bin:$PATH
else
    echo "Please set your HTS_PIPELINE_HOME environment variable"
fi

if [[ $USER == genomics ]]; then
    # Set genomics data path
    export SHARED_GENOMICS=/bigdata/genomics/shared

    # Send email notifications to this address
    export NOTIFY_EMAIL=hts@biocluster.ucr.edu
else
    # Set genomics data path
    GROUP=$(id -g -n)
    export SHARED_GENOMICS=/bigdata/$GROUP/$USER/genomics_shared
    if [[ ! -f $SHARED_GENOMICS ]]; then
        mkdir -p $SHARED_GENOMICS/Runs
        mkdir -p $SHARED_GENOMICS/RunAnalysis
    fi

    # Send email notifications to this address
    USER_NAME=$(getent passwd|grep $USER|cut -d: -f5 |tr ' ' '.'|awk '{print tolower($0)}')
    export NOTIFY_EMAIL=$USER_NAME@ucr.edu
fi
