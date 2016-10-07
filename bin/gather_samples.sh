#!/bin/bash

# In order to test the regex within the rename script it may be useful to gather all the samples for each sequencer to test the current regex
find . -maxdepth 2 -name '*_SN*' -type d -exec ls -l {} \; | grep 'fastq.gz$' | awk '{print $6,$7,$8,$9}' > hiseq_sample_files.txt
find . -maxdepth 2 -name '*_M0*' -type d -exec ls -l {} \; | grep 'fastq.gz$' | awk '{print $6,$7,$8,$9}' > miseq_sample_files.txt
find . -maxdepth 2 -name '*_NB*' -type d -exec ls -l {} \; | grep 'fastq.gz$' | awk '{print $6,$7,$8,$9}' > nextseq_sample_files.txt

# After running the above please test that the total lines in these files match your regex
#
# For example:
#    grep -P '_S[0-9]+(_L[0-9]+){0,1}_R[1-2]_[0-9]+\.fastq\.gz$' nextseq_sample_files.txt | grep -v Undetermined | wc -l
#
#
