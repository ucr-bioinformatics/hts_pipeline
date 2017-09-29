#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem-per-cpu=4G
#SBATCH --time=10:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p batch

if [[ $# -lt 1  || $# -gt 2 ]]; then
    echo 'Usage: remove_phiX.sh <FC_ID> [PAIRED_END=0]'
    exit 1
fi

FC_ID=$1
PAIRED_END=${2:-0}

PHIX_DIR="${HTS_PIPELINE_HOME}/resources/phix"
NUM_CORES=32

cd "${SHARED_GENOMICS}/${FC_ID}/"

module load bowtie2

if [[ $PAIRED_END -eq 1 ]]; then
    PAIR1_FILES=$(ls "${SHARED_GENOMICS}/${FC_ID}/"*.fastq.gz | grep 'pair1')
    PAIR2_FILES=$(ls "${SHARED_GENOMICS}/${FC_ID}/"*.fastq.gz | grep 'pair2')
    ALL_FILES=$(echo -e "${PAIR1_FILES}\n${PAIR2_FILES}")

    for f in $ALL_FILES; do
        gzip -cd "$f" > "${f%.gz}"
    done

    PAIR1_LIST=$(echo "$PAIR1_FILES" | tr "\n" ",")
    PAIR2_LIST=$(echo "$PAIR2_FILES" | tr "\n" ",")

    # -p: The number of threads
    # --un-conc-gz: Output path for the gzipped file with unaligned reads
    # --al-conc-gz: Output path for the gzipped file with aligned reads
    # -x: The input file to align against (phix in this case)
    # -1, -2: comma-seperated list of the files to align, where -1 is the first pair and -2 is the second pair
    # -S: the output sam file
    bowtie2 -p ${NUM_CORES} --un-conc-gz "./${FC_ID}_phiX_align.fastq.gz" --al-conc-gz "./${FC_ID}_phiX_align.fastq.gz" -x "${PHIX_DIR}/phix.fasta" -1 "${PAIR1_LIST}" -2 "${PAIR2_LIST}" -S "${FC_ID}_phiX.sam"
else
    FC_FILES=$(ls "${SHARED_GENOMICS}/${FC_ID}"/*.fastq.gz)
    FILE_LIST=$(echo "$FC_FILES" | tr "\n" ",")
    
    for f in $FC_FILES; do
	gzip -cd "$f" > "${f%.gz}"
    done

    cp "${PHIX_DIR}"/phix.fasta* .

    # -p: The number of threads
    # --un-conc-gz: Output path for the gzipped file with unaligned reads
    # --al-conc-gz: Output path for the gzipped file with aligned reads
    # -x: The input file to align against (phix in this case)
    # -U: comma-seperated list of the files to align
    # -S: the output sam file
    bowtie2 -p ${NUM_CORES} --un-conc-gz "./${FC_ID}_phiX_align.fastq.gz" --al-conc-gz "./${FC_ID}_phiX_align.fastq.gz" -x "${PHIX_DIR}/phix.fasta" -U "${FILE_LIST}" -S "${FC_ID}_phiX.sam"
fi

