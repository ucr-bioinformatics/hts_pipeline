#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=50G
#SBATCH --time=2:00:00
#SBATCH --mail-user=${7}
#SBATCH --mail-type=ALL
#SBATCH -p short

sleep $(($RANDOM % 10))
${1}_start.sh ${2} ${3}/${4} ${1} ${5}
