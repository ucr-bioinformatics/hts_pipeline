#!/bin/bash

if [ ! -z $HTS_PIPELINE_HOME ]; then
    export PATH=$HTS_PIPELINE_HOME/bin:$PATH
else
    echo "Please set your HTS_PIPELINE_HOME environment variable"
fi
