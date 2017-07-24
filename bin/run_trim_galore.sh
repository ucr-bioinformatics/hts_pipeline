#!/bin/bash -l

#############################################
# Check for NextSeq data and execute pipeline #
#############################################

# Set global vars
source $HTS_PIPELINE_HOME/env_profile.sh

FC_ID=$1

# Generate second QC report
ls $SHARED_GENOMICS/$FC_ID/*.fastq.gz > $SHARED_GENOMICS/$FC_ID/file_list_new.txt

while IFS= read -r file
    do
        [ -f "$file" ]
        module load slurm
        sbatch trim_galore_wrapper.sh ${SHARED_GENOMICS} ${FC_ID} ${file}
    done < "file_list_new.txt"
