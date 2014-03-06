#!/bin/bash

########################################################################
# Simple script to move files from Clay's upload to the shared bigdata #
########################################################################

# Get flowcell IDs
FCs=$1

# Loop through all flowcells
for FC in $FCs
do
    echo echo "Starting $FC..."
    # Be careful when running this, it DELETES the source files!
    rsync -a --progress --remove-source-files /bigdata/cclark/flowcell$FC/ /shared/genomics/$FC
    echo "...Transfer Complete"
done

