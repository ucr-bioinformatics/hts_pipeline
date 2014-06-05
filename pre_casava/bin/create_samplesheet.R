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

shared_genomics <- Sys.getenv("SHARED_GENOMICS")
setwd(paste(shared_genomics,"/",flowcellid,"/",rundir,"/",sep=""))

command <- paste("cp",samplesheet,"SampleSheet_old.csv",sep=" ")
system(command)

# Connect to Database
require(RMySQL, quietly = TRUE)
con <- dbConnect(MySQL(), user="webuser", password="5any77z1",dbname="projects", host="illumina.bioinfo.ucr.edu")

# Get sample and project ids
flowcell_table <- dbGetQuery(con,paste("SELECT * FROM flowcell_list where flowcell_id = ", flowcellid," LIMIT 1",sep=""))
lane=1
i=1
label <- flowcell_table$label
project_id <- flowcell_table[paste("lane_",i,"_project",sep="")][[1]]

#samplesheet_file <- scan("SampleSheet.csv")

library(data.table)
a <- read.delim(samplesheet, sep=",")
line_data <- rownames(a[ grep("Data",a[,1]), ])
line_num <- as.numeric(as.character(line_data))

a = fread(samplesheet, skip=(line_num+1))
len_a <- length(a$index)

cat(paste("FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject", sep=","),file="SampleSheet.csv","\n")
for (j in (1:len_a)){
	line <- cat(paste(label,i,j,"",a$index[j],"","N","","nkatiyar",project_id,sep=","),file="SampleSheet.csv","\n", append=TRUE)
		}

#read.table(header=FALSE, text=s)

