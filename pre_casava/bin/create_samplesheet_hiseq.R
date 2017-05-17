#!/usr/bin/env Rscript
#Miseq samplesheet conversion

## Author Neerja Katiyar

# Get script arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    stop("USAGE:: script.R <FlowcellID> <Samplesheet> <Rundir>")
}
flowcellid <- args[1]
samplesheet <- args[2]
rundir <- args[3]

print("Starting generation of SampleSheet")

# Connect to Database
require(RMySQL, quietly = TRUE)
con <- dbConnect(MySQL(), user="webuser", password="5any77z1",dbname="projects", host="illumina.int.bioinfo.ucr.edu")

# Get sample and project ids
flowcell_table <- dbGetQuery(con,paste("SELECT * FROM flowcell_list where flowcell_id = ", flowcellid," LIMIT 1",sep=""))
#lane=1
#i=1
label <- flowcell_table$label

#samplesheet_file <- scan("SampleSheet.csv")

samplesheet_file <- read.table(samplesheet, header=TRUE, sep="\t",stringsAsFactors = !default.stringsAsFactors(),strip.white = TRUE)
num_lanes <- length(samplesheet_file$Indices)
lane <- samplesheet_file$Lane
lane <- gsub("Lane","", lane)
#print(lane)
lane <- lapply(lane, as.numeric)

Indices_new <- samplesheet_file$Indices
Indices_new <- gsub(" ","", Indices_new)
Indices_new <- gsub("and",",", Indices_new)
#print(Indices_new)
cnt = 0
sample_id=0

setwd(paste(Sys.getenv("SHARED_GENOMICS"),flowcellid,sep="/"))
cat(paste("FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject", sep=","),file="SampleSheet_rename.csv")

for (j in lane){
	#print(j)
	cnt=cnt+1
	index_list <- strsplit(Indices_new[cnt],",")
	#print(index_list[[1]][1])
	index_len <- (lapply(index_list, function(x) length(x)))
	#print(index_len[[1]])
	#print(length(index_len))
	project_id <- flowcell_table[paste("lane_",j,"_project",sep="")][[1]]
	#print(project_id)
	project_id_new <- gsub(" ","",project_id)
	for (k in (1:index_len[[1]])){
		#print(k)
        sample_id = sample_id +1
		index_val <- gsub(" ", "", index_list[[1]][k])
		line <- cat(paste("\n",label,",",j,",",sample_id,",,",index_val,",,","N,",",","nkatiyar,",project_id_new,sep=""),file="SampleSheet_rename.csv", append=TRUE)
	}
}
