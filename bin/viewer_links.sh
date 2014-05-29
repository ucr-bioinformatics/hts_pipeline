#!/bin/bash

###############################
# Create symlinks for viewers #
###############################

# Check Arguments
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {/path/to/source} {/path/to/target}"
  exit $E_BADARGS
fi

SOURCE_DIR=$1
TARGET_DIR=$2

# Delete broken symlinks
symlinks -d $TARGET_DIR > /dev/null

# Change directory to source
cd $SOURCE_DIR

# Get list of Run directories
dir_list=`find . -maxdepth 1 -type d`
# Iterate over each Run directory
for dir in $dir_list; do 
    # Check if directory is not source directory
    if [ "$dir" != '.' ]; then
        # Get flowcell ID based on last 9 chars of directory name
        str=`echo $dir | cut -d_ -f4`
        str=${str:1:10}

        # Pull chars from dir name then query mysql...
        QUERY="SELECT flowcell_id FROM flowcell_list WHERE label=\"$str\";"
        flowcellID=flowcell`mysql -hillumina.bioinfo.ucr.edu -Dprojects -u***REMOVED*** -p***REMOVED*** -N -s -e "SELECT flowcell_id FROM flowcell_list WHERE label=\"$str\";"`

        # Check if symlink already exists in target directory
        if [ ! -h "$TARGET_DIR/$flowcellID" ]; then
            # Create symlink from source to target
            ln -s $SOURCE_DIR/$dir $TARGET_DIR/$flowcellID
        else
            echo "Symlink $TARGET_DIR/$flowcellID already exists"
        fi
    fi
done

