#!/bin/bash -l

########################
# Start HTS Pipeline #
########################

echo "started running"

# Set global vars
source $HTS_PIPELINE_HOME/env_profile.sh

# Change directory to source
SOURCE_DIR="${SHARED_GENOMICS}/Runs"
cd $SOURCE_DIR

# Get list of Run directories
dir_list=`find . -maxdepth 1 -type d`
# Iterate over each Run directory
for dir in $dir_list; do
    # Check if directory is not source directory
    if [ "$dir" != '.' ]; then
        # Find sample sheet
        complete_file=`find $dir -name RTAComplete.txt`

        if [ ! -z $complete_file ]; then
            # Determin Sequencer type
            str=$(echo $dir | cut -d_ -f2)
            case $str in
            ["SN279"]*)
                SEQ="hiseq"
            ;;
            ["NB501124"]*)
                SEQ="nextseq"
            ;;
            ["M02457"]*)
                SEQ="miseq"
            ;;
            *)
                SEQ="default"
            ;;
            esac

            # Pull chars from dir name
            str=$(echo $dir | grep -oP "[A-Z0-9]+$")
            if [[ ${#str} -eq 10 ]]; then
                label=${str:1:10}
            else
                label=$str
            fi
            
            # Determine flowcell ID
            QUERY="SELECT flowcell_id FROM flowcell_list WHERE label=\"$label\";"
            FC_ID=$(mysql -hillumina.int.bioinfo.ucr.edu -Dprojects -u***REMOVED*** -p***REMOVED*** -N -s -e "${QUERY}")


            # Send email notification
            echo "Sending Mail"
            /usr/sbin/sendmail -vt << EOF
To: ${NOTIFY_EMAIL}
From: no-reply@biocluster.ucr.edu
Subject: HTS Pipeline: Flowcell ${FC_ID}: Started

Flowcell ${FC_ID} has come in and needs to be processed.
Thanks
EOF
            echo "Processing ${FC_ID} from ${SOURCE_DIR}/$dir" >> ${HTS_PIPELINE_HOME}/log/${SEQ}_pipeline.log
            echo ${SEQ}_start.sh ${FC_ID} ${SOURCE_DIR}/$dir | qsub -l nodes=1:ppn=64,mem=50gb -j oe -o ${HTS_PIPELINE_HOME}/log/${SEQ}_start.log -m bea -M ${NOTIFY_EMAIL}
        fi
    fi
done

#########################
# Start HiSeq Pipeline? #
#########################

exit $?
