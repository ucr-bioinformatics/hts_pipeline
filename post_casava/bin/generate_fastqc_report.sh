#!/bin/bash -l

# Check number of arguments
if (( $# < 1 )); then
    echo "Usage: $(basename $0) FC_ID [NUM_LANES = 0] [SUBMIT_JOB = 0]"
    exit 1
fi

FC_ID=$1
NUM_LANES=${2:-0}
SUBMIT_JOB=${3:-0}

if [ ! -d "${SHARED_GENOMICS}/${FC_ID}" ]; then
    echo "Flowcell #${FC_ID} not found."
    exit 1
fi

# Generate second QC report
if (( NUM_LANES == 0 && SUBMIT_JOB == 0 )); then
    mkdir -p "${SHARED_GENOMICS}/${FC_ID}/fastq_report"
    module load fastqc
    fastqc -t 10 -o "${SHARED_GENOMICS}/${FC_ID}/fastq_report/" $(echo $SHARED_GENOMICS/$FC_ID/*.fastq.gz)
elif (( NUM_LANES == 0 && SUBMIT_JOB == 1)); then
    mkdir -p "${SHARED_GENOMICS}/${FC_ID}/fastq_report"
    module load slurm
    sbatch generate_qc_report_wrapper.sh ${SHARED_GENOMICS} ${FC_ID} 0 "$(echo $SHARED_GENOMICS/$FC_ID/*.fastq.gz)"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to add FastQC report generation to slurm queue. Exiting."
        exit 1
    fi
else
    for (( i = 1; i <= NUM_LANES; i++ ))
    do
        mkdir -p fastq_report/fastq_report_lane${i}/
        ls $SHARED_GENOMICS/$FC_ID/*lane${i}*.fastq.gz > $SHARED_GENOMICS/$FC_ID/file_list_new${i}.txt
        
        while IFS= read -r file
        do
            [ -f "$file" ]
            module load slurm
            sbatch -J "FASTQC_${FC_ID}" generate_qc_report_wrapper.sh ${SHARED_GENOMICS} ${FC_ID} ${i} ${file}

            if [ $? -ne 0 ]; then
                echo "ERROR: Failed to add FastQC report generation to slurm queue. Exiting."
                exit 1
            fi
        done < $SHARED_GENOMICS/$FC_ID/file_list_new${i}.txt
    done
fi
