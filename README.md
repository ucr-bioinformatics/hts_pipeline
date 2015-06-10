Pre-CASAVA
==========
1. Move sequencer run directory from Runs to RunAnalysis
2. Create symlink from run directory back to Runs
3. Build SampleSheet

CASAVA
======
1. Run CASAVA
2. Copy SampleSheet from BaseCalls to FASTQs directory (beside the Unaligned output)

Post-CASAVA
===========
1. Rsync data from HTS to Biocluster
2. Rename FASTQ files
3. Generate QC report
2. Update links on Illumina web server

Analysis
========
1. Align Reads
2. Trim Reads

Dependencies
============
1. data.table (CRAN R package)
