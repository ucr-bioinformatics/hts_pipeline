#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: send_flowcell_email.sh <FC_ID>"
    exit 1
fi

# Load DB passwords
source "$HTS_PIPELINE_HOME/bin/load_hts_passwords.sh"

# Email information (constants)
EMAIL_SENDER="William Shiao <wshia002@ucr.edu>"
EMAIL_CC="${EMAIL_SENDER}, Clay Clark <clay.clark@ucr.edu>, Glenn Hicks <glenn.hicks@ucr.edu>, Neerja Katiyar <neerja.katiyar@ucr.edu>"

# TODO: Populate variables with information from DB
FC_ID="$1"
FC_EMAIL=$(mysql -D projects -h illumina.int.bioinfo.ucr.edu -u ***REMOVED*** -p -N -s -e "SELECT email FROM flowcell_list INNER JOIN project_list ON project_list.project_id = flowcell_list.lane_1_project WHERE flowcell_id=${FC_ID}")

echo "Sending email for flowcell #${FC_ID} to ${FC_EMAIL}"

MAIL_HEADERS=$(cat <<EOF
From: $EMAIL_SENDER
To: $FC_EMAIL
Cc: $EMAIL_CC
EOF
)

MISEQ_EMAIL=$(cat <<EOF
Dear user(s),

The sequence data from your recent sample submission has been uploaded from Flowcell #${FC_ID} and are available on the HT Sequencing web site (http://illumina.ucr.edu/). To see your data click "Projects and Flowcells" in the Navigation menu, and then click "Download Project Data." The Demultiplex statistics and the sequence quality report can be downloaded from the links under Sequence Quality.

Due to the vastly increased data output of the sequencing instrument, we can only store the raw data on our server for one month and then we delete them permanently. The raw data include pre-base-call data, which are rarely of any use to most NGS projects. However, they would be required for rerunning the Illumina base caller or third party base callers.

Please note, the data were stored in illumina FASTQ format http://illumina.ucr.edu/ht/documentation/data-analysis-docs/CASAVA-FASTQ.pdf/view.

The FASTQ files will be available for download for one year after their generation.  After this time period, they will be deleted.
EOF
)

NEXTSEQ_EMAIL=$(cat << EOF
Dear user(s),

The sequence data from your recent sample submission has been uploaded from Flowcell #${FC_ID} and are available on the HT Sequencing web site (http://illumina.ucr.edu/). To see your data click "Projects and Flowcells" in the Navigation menu, and then click "Download Project Data." The Demultiplex statistics and the sequence quality report can be downloaded from the links under Sequence Quality.

Due to the vastly increased data output of the NextSeq instrument, we can only store the raw data on our server for one month and then we delete them permanently. The raw data include pre-base-call data, which are rarely of any use to most NGS projects. However, they would be required for rerunning the Illumina base caller or third party base callers.


Please note, the data were stored in illumina FASTQ format http://illumina.ucr.edu/ht/documentation/data-analysis-docs/CASAVA-FASTQ.pdf/view.

The FASTQ files will be available for download for one year after their generation.  After this time period, they will be deleted.
EOF
)

if [[ $SEQ == "NextSeq" ]]; then
    EMAIL_BODY="$NEXTSEQ_EMAIL"
elif [[ $SEQ == "MiSeq" ]]; then
    EMAIL_BODY="$MISEQ_EMAIL"
fi

echo "Sending email to $FC_USER"
/usr/sbin/sendmail -t << EOF
$MAIL_HEADERS
Subject: Your $SEQ data (FC #${FC_ID}) is ready to download

$EMAIL_BODY

Thank you.

-- 
William Shiao
IIGB Student Programmer

EOF

