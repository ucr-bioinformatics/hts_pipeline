#!/usr/bin/env Rscript

### Generate renamed sym-links for FASTQ files
## Jordan Hayes
## 2/3/2014

# Get script arguments
#args <- c('219','2','SampleSheet.csv','.')
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 6) {
    stop("USAGE:: script.R <FlowcellID> <NumberOfFiles> <SampleSheet> <UnalignedPath> <RunType> <RunDir>")
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

# Trim off leading and trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

# Define function to be applied to each row
gen_link <- function(x) {
    project_id <-  trim(x[10])
    sample_id <- trim(x[3])
    lane <- trim(x[2])
    index <- trim(x[5])

    # Find files based on file name pattern
	
    if (run_type == "hiseq"){
       	#file_name <- paste(sample,"_.*_L00",lane[i],"_R", p, ".*fastq.gz$", sep="")
        fastq_path <- paste(unaligned_path,'/',project_id,'/',sep="")
        file_name <- paste("^",sample_id,"_.*_L00",lane,"_R", p, ".*fastq.gz$", sep="")
        print(paste(fastq_path,file_name))
        files <- list.files(path=fastq_path,pattern=file_name)       	

        # Get undetermined files
        ufastq_path <- paste(unaligned_path,'/',sep="")
        file_name_undermine <-paste(".*Undetermined.*_L00",lane,"_[R|I]", p, ".*fastq.gz$", sep="")
        files_undermine <- list.files(path=ufastq_path,pattern=file_name_undermine)

        # Join fastqs and undetermined
        files <- list(files,list(),files_undermine,list())
         
   } else {
        # Define path
        fastq_path <- unaligned_path
        ufastq_path <- unaligned_path

        # Get fastq files
        file_name <- paste("[^0-9]",sample_id,"_L00",lane,"_R", p, ".*fastq.gz$", sep="")
        files <- list.files(path=fastq_path,pattern=file_name)
        if (length(files) == 0 && run_type == "nextseq") {
            file_name <- paste(sample_id,"_R", p,"_[0-9]+.fastq.gz$", sep="")
            files <- list.files(path=fastq_path,pattern=file_name)
        }
        
        # Get undetermined files
        file_name_undermine <-paste("Undetermined.*_L00",lane,"_R", p, ".*fastq.gz$", sep="")
        files_undermine <- list.files(path=ufastq_path,pattern=file_name_undermine)

        # Get fastq files
        ifile_name <- paste("[^0-9]",sample_id,"_L00",lane,"_I", p, ".*fastq.gz$", sep="")
        ifiles <- list.files(path=fastq_path,pattern=ifile_name)

        # Get undetermined files
        ifile_name_undermine <-paste("Undetermined.*_L00",lane,"_I", p, ".*fastq.gz$", sep="")
        ifiles_undermine <- list.files(path=ufastq_path,pattern=ifile_name_undermine)
        
        # Join undetermined and others
        files <- list(files,ifiles,files_undermine,ifiles_undermine)
    } 
	
    # If we found some files, create symlinks  
    for ( i in 1:length(files)) {
        for(f in files[i]) {
            if ( length(f) > 0) {
                if ( i==4 ) {
                    # Processes Undetermined Index files 
                    commands <- paste("ln -s ",ufastq_path,'/',f, "  ", "Undetermined_lane",lane,"_pair",index_pair_num,".fastq.gz",sep="")
                    #index_pair_num <- index_pair_num + 1
                } else if ( i==3 ) { 
                    # Processes Undetermined files
                    commands <- paste("ln -s ",ufastq_path,'/',f, "  ", "Undetermined_lane",lane,"_pair",p,".fastq.gz",sep="")
                } else if ( i==2 ) {
                    # Processes Index files (I1,I2,etc...)
                    if (!is.na(index)) {
                        commands <- paste("ln -s ",fastq_path,'/',f, "  ", flowcell, "_lane",lane,"_pair",index_pair_num,"_",index,".fastq.gz",sep="")
                    }
                    else {
                        commands <- paste("ln -s ",fastq_path,'/',f, "  ", flowcell, "_lane",lane,"_pair",index_pair_num,".fastq.gz",sep="")
                    }
                } else if ( i==1 ) {
                    # Processes sequence files (R1,R2,etc...)
                    if (!is.na(index)) {
                        commands <- paste("ln -s ",fastq_path,'/',f, "  ", flowcell, "_lane",lane,"_pair",p,"_",index,".fastq.gz",sep="")
                    } else {
                        commands <- paste("ln -s ",fastq_path,'/',f, "  ", flowcell, "_lane",lane,"_pair",p,".fastq.gz",sep="")
                    }
                } else {
                    warning(paste("ERROR: Index",i,"out of bounds."))
                }
        
                print(commands)
                system(commands)
            } else {
               warning(paste("WARNING:: No files matching pattern ",file_name," i=",i))
            }
        }
    } 
}

# For each pair generate sym links for each row
index_pair_num <- pairs[length(pairs)]
for (p in pairs){
    apply(samples, 1, gen_link)
}

# Print first warnings
warn <- warnings()
if (length(warn) > 0){
    print(warn)
}

# Create QC sym-link
qcs <- list.files(path=unaligned_path, pattern='^qc[0-9]*$')
if (length(qcs) > 1) {
    last_qc <- qcs[-1]
    next_qc <- paste('qc', is.numeric(gsub("^qc", '',last_qc))+1, sep="")
}else {
    next_qc <- 'qc'
}
system(paste('ln -s ', unaligned_path, '/Reports/html/ ', next_qc, sep=""))

print("Rename complete")
