#!/bin/bash

# Add hts tools to PATH
if [ ! -z $HTS_PIPELINE_HOME ]; then
    export PATH=$HTS_PIPELINE_HOME/bin:$PATH
else
    echo "Please set your HTS_PIPELINE_HOME environment variable"
fi

# Set genomics data path
export SHARED_GENOMICS=/bigdata/genomics/shared

# Send email notifications to this address
export NOTIFY_EMAIL=hts@biocluster.ucr.edu
