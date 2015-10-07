#!/bin/bash -l

# Check Arguments
EXPECTED_ARGS=3
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {FlowcellID} {RunDirectoryName} {BaseMask} {SampleSheet}"
  exit $E_BADARGS
fi

# Get args
fc_id=$1
run_dir=$2
base_mask=$3
samplesheet=$4

module load bcl2fastq
cd $SHARED_GENOMICS/RunAnalysis/flowcell$fc_id
echo "Creating output directory..."
mkdir -p $SHARED_GENOMICS/$fc_id/$run_dir
echo "Running bcl2fastq for demultiplexing..."

if [[ ! "${base_mask}" == "NA" ]]; then
    echo -e "\tRunning with BaseMask ${base_mask}"
    bcl2fastq --use-bases-mask=$base_mask --runfolder-dir=$run_dir --sample-sheet=$samplesheet --processing-threads=64 --demultiplexing-threads=12 --loading-threads=4 --writing-threads=4 --output-dir=$SHARED_GENOMICS/$fc_id/$run_dir 2>&1 | tee $SHARED_GENOMICS/$fc_id/nohup.out
else
    echo -e "\tRunning with out BaseMask"
    bcl2fastq --runfolder-dir=$run_dir --sample-sheet=$samplesheet --processing-threads=64 --demultiplexing-threads=12 --loading-threads=4 --writing-threads=4 --output-dir=$SHARED_GENOMICS/$fc_id/$run_dir 2>&1 | tee $SHARED_GENOMICS/$fc_id/nohup.out
fi

