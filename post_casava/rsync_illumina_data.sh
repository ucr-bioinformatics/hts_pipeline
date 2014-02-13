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
    rsync -a --progress -e "ssh -i /root/.ssh/genomics_nfs_rsa" /home/casava_fastqs/$FC/ genomics@nfs02.bioinfo.ucr.edu:/pool0/bigdata/genomics/shared/$FC
    echo "...Transfer Complete"
done

