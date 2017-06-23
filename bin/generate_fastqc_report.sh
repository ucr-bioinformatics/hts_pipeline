#!/bin/bash -l

# Check number of arguments
if (( $# != 2 )); then
    echo "Usage: $(basename $0) FC_ID"
fi

FC_ID=$1

# Generate second QC report
ls $SHARED_GENOMICS/$FC_ID/*.fastq.gz > $SHARED_GENOMICS/$FC_ID/file_list_new.txt
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate file list. Exiting."
    exit 1
fi

while IFS= read -r file
do
    [ -f "$file" ]
    module load slurm
    # echo "module load fastqc; fastqc -o $SHARED_GENOMICS/$FC_ID/fastq_report/ $file" | qsub -lnodes=1:ppn=4,mem=16g,walltime=4:00:00;
    CMD="sbatch generate_qc_report_wrapper.sh ${SHARED_GENOMICS} ${FC_ID} ${file} 0"
    ${CMD}
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to add QC report generation #2 to slurm queue. Exiting."
	exit 1
    fi
done < $SHARED_GENOMICS/$FC_ID/"file_list_new.txt"

