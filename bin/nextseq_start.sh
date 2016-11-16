#!/bin/bash -l

#############################################
# Check for NextSeq data and execute pipeline #
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
    lockfile-create -r 0 $SOURCE_DIR/${SEQ}_start || ( echo "Could not create $SOURCE_DIR/$lockfile" && exit 1 )

    # Set error file
    ERROR=0
    export ERROR_FILE=$SHARED_GENOMICS/$FC_ID/error.log
    mkdir -p $SHARED_GENOMICS/$FC_ID
    echo "Starting Pipeline" > $ERROR_FILE
    
    ##################
    # Pipeline Steps #
    ##################
   
    # Create copy of the original samplesheet from Clay and name it as SampleSheet.csv
    samplesheet_origfile=$(ls ${SHARED_GENOMICS}/Runs/$run_dir/*_FC#*.csv)
    CMD="cp $samplesheet_origfile SampleSheet.csv"
    echo -e "==== Create copy of the original samplesheet from Clay STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: Create copy of original samplesheet failed" >> $ERROR_FILE && ERROR=1
        fi
    fi
    
    # Looks to change any + and . in the labeling 
    cat SampleSheet.csv | sed '1,/Data/!d' > SampleSheet_new.csv
    cat SampleSheet.csv | sed '1,/Data/d' |
    while IFS='' read -r line || [[ -n "$line" ]]
    do
        #FIRSTHALF=$(echo $line | cut -d, -f1 | sed -e 's/\./_/g' -e 's/+/_/g' -e 's/\ /_/g')
        FIRSTHALF=$(echo $line | sed -e 's/\./_/g' -e 's/+/_/g' -e 's/\ /_/g')
        SECONDHALF=${line:${#FIRSTHALF}}
        echo $FIRSTHALF$SECONDHALF >> SampleSheet_new.csv
    done
    mv SampleSheet_new.csv SampleSheet.csv
 
    # Transfer nextseq data
    CMD="transfer_data.sh $FC_ID $SOURCE_DIR"
    echo -e "==== Transfer STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: Transfer failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Get barcode length
    barcode=$(tail -1 ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv | awk '{split($0,a,","); print a[6]}')
    dual_index_flag=0
    # Create Sample Sheet for demux
    if [ $ERROR -eq 0 ]; then
        numpair=$(( $(ls ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/RTARead*Complete.txt | wc -l) - 1 ))
        if [ ${numpair} >= 3 ]; then #Dual indexing
            dual_index_flag=1
            NUMFILES=$(( $numpair - 1 ))
            numpair=$(( $numpair - 1 ))
        else
            NUMFILES=$numpair
        fi
        MUX=1
        BASEMASK="NA"
    fi
    
    echo -e "====  DETERMINE TYPE of DEMUX STEP ====\n" >> $ERROR_FILE
    # Determine type of demultiplexing
    #if [ $ERROR -eq 0 ]; then
        #${CMD} &>> $ERROR_FILE
        #if [ $? -ne 0 ]; then
            #echo "ERROR:: Finding barcode failed" >> $ERROR_FILE && ERROR=1
        #fi
    #fi
    
    #Default arguments for most common type of demux
    #numpair=$(( $(ls ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/RTARead*Complete.txt | wc -l) - 1 ))
    #NUMFILES=$numpair
    #MUX=1
    #BASEMASK="NA"
    
    # We will demultiplex and barcode is of standard length 6 (single-end,paired-end)
    if [[ ${#barcode} == 6 ]]; then
       MUX=1
       BASEMASK="NA"
    fi
    
    #We will demultiplex and the barcode is of different length and single-end
    if [ ${#barcode} > 6 ] && [ ${numpair} == 1 ]; then
        MUX=1
        BASEMASK="Y*,I${#barcode},Y*"
        NUMFILES=1
    fi

    #User demultiplexes and it is single end
    if [ ${numpair} == 1 ] && [ ${#barcode} == 0 ]; then
        MUX=2
        BASEMASK="Y*,Y*"
        NUMFILES=2
    fi

    #User will demultiplex and it is paired-end
    if [ ${numpair} == 2 ] && [ ${#barcode} == 0 ]; then
       MUX=2
       BASEMASK="Y*,Y*,Y*"
       NUMFILES=3
    fi
    
    # Create Sample Sheet
    # They demux
    #CMD="bcl2fastq_run.sh ${FC_ID} $run_dir Y*,Y* ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv 1"
    # We demux
    CMD="bcl2fastq_run.sh ${FC_ID} $run_dir $BASEMASK ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv 1 nosplit"
    echo -e "==== DEMUX STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        cd $SHARED_GENOMICS/$FC_ID
        ${CMD} &> nohup.out
        if [ $? -ne 0 ]; then
            echo "ERROR:: Demuxing failed" >> $ERROR_FILE && ERROR=1
        fi
    fi
    
    # Create Sample Sheet
    if [ $dual_index_flag == 1 ]; then
        CMD="create_samplesheet_${SEQ}_i5_i7.R ${FC_ID} ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv $run_dir"
    else
        CMD="create_samplesheet_${SEQ}.R ${FC_ID} ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/SampleSheet.csv $run_dir" 
    fi
    echo -e "==== SAMPLE SHEET STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR:: SampleSheet creation failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Rename Files
    CMD="fastqs_rename.R $FC_ID ${NUMFILES} $run_dir/SampleSheet.csv $run_dir ${SEQ} $run_dir"
    echo -e "==== RENAME STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then 
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then 
            echo "ERROR: Files rename failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Generate QC report
    CMD="qc_report_generate_targets.R $FC_ID ${numpair} $SHARED_GENOMICS/$FC_ID/ $SHARED_GENOMICS/$FC_ID/fastq_report/ $SHARED_GENOMICS/$FC_ID/$run_dir/SampleSheet.csv $MUX"
    echo -e "==== QC STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR: QC report generation failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Update Illumina web server URLs
    CMD="sequence_url_update.R $FC_ID 1 $SHARED_GENOMICS/$FC_ID"
    echo -e "==== URL STEP ====\n${CMD}" >> $ERROR_FILE
    if [ $ERROR -eq 0 ]; then 
        ${CMD} &>> $ERROR_FILE
        if [ $? -ne 0 ]; then
            echo "ERROR: Illumina URL update failed" >> $ERROR_FILE && ERROR=1
        fi
    fi

    # Remove lock files
    chmod u+w ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir
    rm -f ${SHARED_GENOMICS}/RunAnalysis/flowcell${FC_ID}/$run_dir/$lockfile
fi

# Exit
exit $ERROR

