#!/bin/bash -l

# Check number of arguments
if (( $# < 2 )); then
    echo "Usage: $(basename $0) FC_ID [NUM_LANES]"
    exit 1
fi

FC_ID=$1
if (( $# == 2 )); then
    NUM_LANES=0
else
    NUM_LANES=$2
fi

# Generate second QC report
if (( NUM_LANES == 0 )); then
    ls $SHARED_GENOMICS/$FC_ID/*.fastq.gz > $SHARED_GENOMICS/$FC_ID/file_list_new.txt
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to generate file list. Exiting."
        exit 1
    fi

    while IFS= read -r file
    do
        [ -f "$file" ]
        module load slurm
        sbatch generate_qc_report_wrapper.sh ${SHARED_GENOMICS} ${FC_ID} ${file} 0

        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to add FastQC report generation to slurm queue. Exiting."
            exit 1
        fi
    done < $SHARED_GENOMICS/$FC_ID/file_list_new.txt
else
    for (( i=1; i<=$NUM_LANES; i++ ))
    do
        mkdir -p fastq_report/fastq_report_lane${i}/
        ls $SHARED_GENOMICS/$FC_ID/*lane${i}*.fastq.gz > $SHARED_GENOMICS/$FC_ID/file_list_new${i}.txt
        
        while IFS= read -r file
        do
            [ -f "$file" ]
            module load slurm
            sbatch generate_qc_report_wrapper.sh ${SHARED_GENOMICS} ${FC_ID} ${file} ${i}

            if [ $? -ne 0 ]; then
                echo "ERROR: Failed to add FastQC report generation to slurm queue. Exiting."
                exit 1
            fi
        done < $SHARED_GENOMICS/$FC_ID/file_list_new${i}.txt
    done
fi
