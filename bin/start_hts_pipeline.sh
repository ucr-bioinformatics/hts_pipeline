#!/bin/bash -l
touch $HTS_PIPELINE_HOME/log/miseq_pipeline.log
echo "miseq_start.sh /bigdata/cclark/" | qsub -l nodes=1:ppn=8,mem=10gb -m aeb -M hts@biocluster.ucr.edu
