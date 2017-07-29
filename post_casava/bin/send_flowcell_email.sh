#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: send_flowcell_email.sh <FC_ID>"
    exit 1
fi

# Load DB passwords
source "$HTS_PIPELINE_HOME/bin/load_hts_passwords.sh"

# Email information (constants)
EMAIL_SENDER="wshia002@ucr.edu"
EMAIL_CC="$EMAIL_SENDER"

# TODO: Populate variables with information from DB
FC_USER=""
SEQ=""

MAIL_HEADERS=$(cat <<EOF
To: $FC_USER
From: $EMAIL_SENDER
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

