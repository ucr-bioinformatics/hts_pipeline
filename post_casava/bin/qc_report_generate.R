#!/usr/bin/env Rscript

### Generate FASTQ Quality report in PDF format
## Neerja Katiyar
## 2/4/2014

# Get script arguments
args <- commandArgs(trailingOnly = TRUE)
#args <- c(221,2,'/shared/genomics/221/','/bigdata/nkatiyar/QC_flowcells/221/')
if (length(args) < 4) {
    stop("USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath>")
}
flowcellid <- args[1]
num_pairs <- args[2]
fastq_path <- args[3]
targets_path <- args[4]

# Pull Girke Code
source("http://faculty.ucr.edu/~tgirke/Documents/R_BioCond/My_R_Scripts/fastqQuality.R")

# For each lane target file, process PDF report
for (lane in 1:8) {
    file_pattern <- paste('^targets_lane', lane, '.txt$', sep="")
    target_lane <- list.files(path=targets_path, pattern=file_pattern)

    # Get targets (FASTQ files) for specific lane
    if (length(target_lane) == 1) {
        targets <- read.delim(paste(targets_path, target_lane[1], sep=""))
    } else {
        msg <- paste0("Did not find target file matching ", targets_path, file_pattern, " Skipping...")
        warning(msg)
        next
    }

    # Format files object
    if (num_pairs == 1) {
        myfiles <- paste(fastq_path, targets$FileName, sep="")
        names(myfiles) <- targets$SampleName
    } else if (num_pairs == 2) {
        myfiles1 <- paste(fastq_path, targets$FileName1, sep="")
        names(myfiles1) <-paste(targets$SampleName, "_pair1", sep="")
        myfiles2 <- paste(fastq_path, targets$FileName2, sep="")
        names(myfiles2) <-paste(targets$SampleName, "_pair2", sep="")
        myfiles <- append(myfiles1, myfiles2)
    } else {
        stop(paste("ERROR::", num_pairs, "pairs not supported."))
    }

    # What files are we processing
    	print("Printing myfiles...")
	print(myfiles)

    # Generate PDF Report
    fqlist <- seeFastq(fastq=myfiles, batchsize=50000, klength=8)
    file_name <- paste("flowcell", flowcellid, "_lane", lane, "_fastqReport.pdf", sep="")
    print("Printing report names")
	print(file_name)
	pdf(file_name, height=18, width=8*length(myfiles))
    seeFastqPlot(fqlist)
    dev.off()
}
warnings()

