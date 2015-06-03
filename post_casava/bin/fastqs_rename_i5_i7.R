#!/usr/bin/env Rscript

### Generate renamed sym-links for FASTQ files for i5 and i7 index case.
## Jordan Hayes
## 2/3/2014
#Edited by Neerja Katiyar

# Get script arguments
#args <- c('219','2','SampleSheet.csv','.')
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 6) {
    stop("USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir> <Demultiplex-type 1- CASAVA 2- user will demultiplex>")
}

print("Starting fastq rename")
# Get flowcell name
flowcellid <- args[1]
flowcell <- paste("flowcell",flowcellid,sep="")
rundir <- args[6]

shared_genomics <- Sys.getenv("SHARED_GENOMICS")
setwd(paste(shared_genomics,"/",flowcellid,"/",sep=""))

# Get number of pairs
pairs <- c()
for (i in 1:args[2]){
    pairs <- c(pairs,i)
}

# Get SampleSheet
if (file.exists(args[3])){
    samples <- read.csv(args[3])
    num_samples <- length(samples[,1]) 
} else{
    stop(paste("SampleSheet ", args[3]," does not exist."))
}

# Make sure FASTQ path exists
if (file.exists(args[4])){
    unaligned_path <- args[4]
} else{
    stop(paste("Unaligned path ", args[4]," does not exist."))
}

run_type <- args[5]
demultiplex_type <- args[7]

# Trim off leading and trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

lane <- 1
fastq_path <- unaligned_path

print("checking...")

#file_names_new <- paste(".*","_L00",lane,"_R", 1, ".*fastq.gz$", sep="")
#print(file_names_new)
#files <- list.files(path=fastq_path,pattern=file_name)
#print(files)
#commands <- paste("ln -s ",fastq_path,j,sep="")
#print(commands)
#system(commands)

for(count in 1:2){
    file_name <- paste(".*","_L00",lane,"_R", count, ".*fastq.gz$", sep="")
    
    print(file_name)
    files <- list.files(path=fastq_path,pattern=file_name)
    print(files)
    for (j in files) {
        commands <- paste("ln -s ",fastq_path,j,sep="")
        print(commands)
        system(commands)
}

# Print first warnings
warn <- warnings()
if (length(warn) > 0){
    print(warn)
}

}
print("Rename complete")
