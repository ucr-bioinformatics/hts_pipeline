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
con <- dbConnect(MySQL(), user="webuser", password="5any77z1",dbname="projects", host="illumina.int.bioinfo.ucr.edu")

# Get sample and project ids
flowcell_table <- dbGetQuery(con,paste("SELECT * FROM flowcell_list where flowcell_id = ", flowcellid," LIMIT 1",sep=""))
lane=1
i=1
label <- flowcell_table$label
project_id <- flowcell_table[paste("lane_",i,"_project",sep="")][[1]]

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
len_a <- length(a$index)
#print("Length of a")
#print(len_a)

cat(paste("FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject", sep=","),file="SampleSheet.csv","\n")
for (j in (1:len_a)){
    if(a$index[j]=="NA")
        {
            a$index[j]=""
        }
	line <- cat(paste(label,i,j,"",a$index[j],"","N","","nkatiyar",project_id,sep=","),file="SampleSheet.csv","\n", append=TRUE)
		}

print("Samplesheet created")
#read.table(header=FALSE, text=s)

