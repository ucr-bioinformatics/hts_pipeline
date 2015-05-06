#!/bin/bash

##################################################
# Simple script to backup Illumina data to nfs02 #
##################################################

# Get args
FCs=$1

# Loop through all flowcells
for FC in $FCs
do
    echo "Starting $FC..."
    # Sync files over to NFS server
    rsync -a --progress -e "ssh -i ~/.ssh/genomics_hts_rsa" hts.bioinfo.ucr.edu:/home/casava_fastqs/$FC/ /bigdata/genomics/shared/$FC
    echo "...Transfer Complete"
done

