#!/bin/bash -l

#############################################
# Check for MiSeq data and execute pipeline #
#############################################

# Set global vars
source $HTS_PIPELINE_HOME/env_profile.sh

# Check Arguments
EXPECTED_ARGS=4
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` FC_ID {/path/to/source} SEQ LABEL"
  exit $E_BADARGS
fi

# Change directory to source
FC_ID=$1
SOURCE_DIR=$2
SEQ=$3
LABEL=$4
cd $SOURCE_DIR

# Check for SampleSheet
complete_file=`find $SOURCE_DIR -name RTAComplete.txt`

if [ -f $complete_file ]; then
    # Determine sequencer run directory
    run_dir=`dirname $complete_file`
    dir=`dirname $run_dir`
    run_dir=`basename $run_dir`
    lockfile="${SEQ}_start.lock"
 
    # Set lock file
    lockfile-create -r 0 $run_dir/${SEQ}_start || ( echo "Could not create $run_dir/$lockfile" && exit 1 )

    # Set error file
    ERROR=0
    export ERROR_FILE=$SHARED_GENOMICS/$FC_ID/error.log
    mkdir -p $SHARED_GENOMICS/$FC_ID
    echo "Starting Pipeline" > $ERROR_FILE
    
    ##################
    # Pipeline Steps #
    ##################
    
    # Transfer sequence data
    CMD="transfer_data.sh $FC_ID $SOURCE_DIR"
    echo -e "==== Transfer STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: Transfer failed" >> $ERROR_FILE && ERROR=1
        fi
    fi
    
    # Check if SampleSheet from John exists
    echo -e "==== SAMPLESHEET CHECK STEP ====\n" >> $ERROR_FILE
    if [[ ! -f ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet_John.csv ]]; then
        echo "ERROR:: SampleSheet from John ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet_John.csv does not exist" >> $ERROR_FILE && ERROR=1
    else
        # Create SampleSheet for rename and QC from John's SampleSheet.
        CMD="create_samplesheet_${SEQ}.R ${FC_ID} ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet_John.csv $run_dir"
        echo -e "==== SAMPLE SHEET STEP ====\n${CMD}" >> $ERROR_FILE
        if [ $ERROR -eq 0 ]; then
            ${CMD} &>> $ERROR_FILE
            if [ $? -ne 0 ]; then
                echo "ERROR:: SampleSheet creation failed" >> $ERROR_FILE && ERROR=1
            fi
        fi
    fi 
    
    #Rename SampleSheet for rename and QC to SampleSheet_rename.csv
    mv ${SHARED_GENOMICS}/${FC_ID}/SampleSheet.csv ${SHARED_GENOMICS}/${FC_ID}/SampleSheet_rename.csv
    # Create Sample Sheet for demux
    if [ $ERROR -eq 0 ]; then
        numpair=$(( $(ls ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/Basecalling_Netcopy_complete_Read*.txt | wc -l) - 1 ))
        date=$(date +"%m/%d/%Y")
        numcycles=$(( $(ls ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/Logs | grep -oP "[0-9]+\.log$" | cut -d. -f1 | sort -n | tail -1) - 1 ))
        if [ $numpair > 1 ]; then
            cycles=$(echo -e "${numcycles},\n${numcycles},\n")
        else
            cycles=$(echo -e "${numcycles},\n")
        fi

    cat << EOF > ${SHARED_GENOMICS}/${FC_ID}/SampleSheet.csv 
[Header]
IEMFileVersion,4
Investigator Name,Neerja Katiyar
Experiment Name,350
Date,${date}
Workflow,GenerateFASTQ
Application,HiSeq FASTQ Only
Assay,TruSeq Small RNA
Description,human small rna
Chemistry,Default

[Reads]
${cycles}

[Settings]
ReverseComplement,0

[Data]
Lane,Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,Sample_Project,Description
EOF
    
        grep -P "^${LABEL}" ${SHARED_GENOMICS}/${FC_ID}/SampleSheet_rename.csv | awk -F ',' '{print $2","$3",,,,,"$5","$10","}' >> ${SHARED_GENOMICS}/${FC_ID}/SampleSheet.csv
    fi

    # They demux
    #CMD="bcl2fastq_run.sh ${FC_ID} $run_dir Y*,Y* ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv 1"
    # We demux
    CMD="bcl2fastq_run.sh ${FC_ID} $run_dir NA ${SHARED_GENOMICS}/${FC_ID}/SampleSheet.csv 1"
    echo -e "==== DEMUX STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        cd $SHARED_GENOMICS/$FC_ID
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: Demuxing failed" >> $ERROR_FILE && ERROR=1
        fi
    fi
    
    # Rename Files
    CMD="fastqs_rename.R $FC_ID ${numpair} ${SHARED_GENOMICS}/${FC_ID}/SampleSheet_rename.csv $run_dir ${SEQ} $run_dir"
    echo -e "==== RENAME STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then 
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then 
            echo "ERROR: Files rename failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Generate QC report
    MUX=1
    CMD="qc_report_generate_targets.R $FC_ID ${numpair} $SHARED_GENOMICS/$FC_ID/ $SHARED_GENOMICS/$FC_ID/fastq_report/ $SHARED_GENOMICS/$FC_ID/SampleSheet_rename.csv $MUX"
    echo -e "==== QC STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR: QC report generation failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Update Illumina web server URLs
    CMD="sequence_url_update.R $FC_ID 8 $SHARED_GENOMICS/$FC_ID"
    echo -e "==== URL STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then 
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR: Illumina URL update failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Remove lock files
    rm -f ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$lockfile
fi

# Exit
exit $ERROR

