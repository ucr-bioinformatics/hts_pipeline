#!/usr/bin/env Rscript

### Generate renamed sym-links for FASTQ files
## Jordan Hayes
## 2/3/2014

# Get script arguments
#args <- c('219','2','SampleSheet.csv','.')
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
    stop("USAGE:: script.R <FlowcellID> <NumberOfPairs> <SampleSheetPath> <FASTQPath>")
}

# Get flowcell name
flowcellid <- args[1]
flowcell <- paste("flowcell",flowcellid,sep="")

# Get number of pairs
pairs <- c()
for (i in 1:args[2]){
    pairs <- c(pairs,i)
}

# Get SampleSheet
if (file.exists(args[3])){
    samples <- read.csv(args[3])
} else{
    stop(paste("SampleSheet ", args[3]," does not exist."))
}

# Make sure FASTQ path exists
if (file.exists(args[4])){
    fastq_path <- args[4]
} else{
    stop(paste("FASTQ path ", args[4]," does not exist."))
}

# Extract needed into
project <- samples$SampleProject
samplenumber <- samples$SampleID
index <- samples$Index
lane <- samples$Lane

# For each pair iterate over samples and rename associated files
for (p in pairs){
    for (proj in project){
        for(i in 1:length(samples[,1])){
            #file_name <- paste(samplenumber[i],"_.*_L00",lane[i],"_R", p, ".*fastq.gz$", sep="")
            file_name <- paste('Project_',proj,'/Sample_','',)
            files <- list.files(path=fastq_path,pattern=file_name)
            if (length(files) > 0){
                if (!is.na(index)){
                    commands <- paste("ln -s ",fastq_path,'/',files, "  ", flowcell, "_lane",lane[i],"_pair",p,"_",index[i],".fastq.gz",sep="")
                }else{
                    commands <- paste("ln -s ",fastq_path,'/',files, "  ", flowcell, "_lane",lane[i],"_pair",p,".fastq.gz",sep="")
                }
                print(commands)
                system(commands)
            } else{
               print(paste("WARNING:: No files matching pattern ",file_name))
            }
        }
    }
}
# Create QC sym-links
# Unaligned/Basecall_Stats_
