#!/bin/bash

#############################################
# Dirty sript to archive old flowcell data. #
#                                           #
# !!!IMPORTANT!!!                           #
# Please note that archives will fail after #
#     flowcell ID reaches 999.              #
#############################################

# Set DIRs
FLOWCELL_DIR=/home/researchers/RunAnalysis
ARCHIVE_DIR=/home/www/html/illumina_runs

# Get list of current archives
cd $ARCHIVE_DIR
ARCHS=( flowcell*.tar.gz )

# Get lastest file
LEN=${#ARCHS[@]}
last=$((LEN - 1))
file=${ARCHS[$last]}
echo $file

# Determine next Flowcell ID
back="${file#"${file%%[[:digit:]]*}"}"
curr="${back%%[^[:digit:]]*}"
echo $curr
FCID=$((curr + 1))

# Create compressed archive of flowcell
tar -zcvf flowcell$FCID.tar.gz -C $FLOWCELL_DIR flowcell$FCID/

# Set permissions
chgrp researchers flowcell$FCID.tar.gz
chmod 440 flowcell$FCID.tar.gz

# Create archive MD5s
echo "Generating archived flowcell MD5Sums"
echo "" > flowcell$FCID.tar.md5
tarsum < flowcell$FCID.tar.gz > flowcell$FCID.tar.md5
sort flowcell$FCID.tar.md5 -o flowcell$FCID.tar.md5

# Create MD5s
cd $FLOWCELL_DIR
echo "Generating flowcell MD5Sums"
echo "" > flowcell$FCID/flowcell$FCID.md5
find flowcell$FCID/ -type f -exec md5sum {} \;>> flowcell$FCID/flowcell$FCID.md5
sort flowcell$FCID/flowcell$FCID.md5 -o flowcell$FCID/flowcell$FCID.md5

echo "Comparing MD5Sums"
DIFFS=`diff $FLOWCELL_DIR/flowcell$FCID/flowcell$FCID.md5 $ARCHIVE_DIR/flowcell$FCID.tar.md5`
echo "$DIFFS"

# If there are no diffs, then proceed to delete flowcell...

