#!/usr/bin/env Rscript
#Hiseq samplesheet conversion

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

shared_genomics <- Sys.getenv("SHARED_GENOMICS")
setwd(paste(shared_genomics,"/",flowcellid,"/",sep=""))

# Load password info
hts_pipeline_home <- Sys.getenv("HTS_PIPELINE_HOME")
source(paste(hts_pipeline_home, "/bin/load_hts_passwords.R", sep = ""))

# Connect to Database
require(RMySQL, quietly = TRUE)
con <- dbConnect(MySQL(), user=hts_pass$db['user'], password=hts_pass$db['pass'],dbname="projects", host="illumina.int.bioinfo.ucr.edu")

# Get sample and project ids
flowcell_table <- dbGetQuery(con,paste("SELECT * FROM flowcell_list where flowcell_id = ", flowcellid," LIMIT 1",sep=""))
lane=1
label <- flowcell_table$label
project_id <- flowcell_table[paste("lane_",lane,"_project",sep="")][[1]]

conn=file(samplesheet,open="r")
line_num <-grep('Data',readLines(samplesheet))
#print("Line numbers Data")
#print(line_num)
close(conn)

#a <- read.delim(samplesheet, sep=",")
#line_data <- rownames(a[ grep("Data",a[,1]), ])
#line_num <- as.numeric(as.character(line_data))

library(data.table)
a = fread(samplesheet, skip=(line_num),header=TRUE)
#print(a)
len_a <- length(a$Sample_ID)
#print("Length of a")
#print(len_a)

cat(paste("FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject", sep=","),file="SampleSheet_rename.csv","\n")

it = 0
for(lane in 1:8){
    if(!sum(a$Lane == lane))
        next
    for (j in (1:sum(a$Lane == lane))){
        it = it + 1
	    line <- cat(paste(label,lane,it,"",a$index[it],"","N","","nkatiyar",project_id,sep=","),file="SampleSheet_rename.csv","\n", append=TRUE)
	}
}

print("Samplesheet created")
#read.table(header=FALSE, text=s)

