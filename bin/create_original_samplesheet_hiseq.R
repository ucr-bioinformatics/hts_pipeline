#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
    stop("USAGE:: script.R <FlowcellID>")
}
flowcellid <- args[1]

# Connect to Database
require(RMySQL, quietly = TRUE)
con <- dbConnect(MySQL(), user="webuser", password="5any77z1",dbname="projects", host="illumina.int.bioinfo.ucr.edu")

# Get sample and project ids
flowcell_table <- dbGetQuery(con,paste("SELECT * FROM flowcell_list where flowcell_id = ", flowcellid," LIMIT 1",sep=""))

#projects <- dbGetQuery(con,paste("SELECT lane_1_project,lane_2_project,lane_3_project,lane_4_project,lane_5_project,lane_6_project,lane_7_project,lane_8_project from flowcell_list WHERE flowcell_id IN (" , flowcellid, " )"))
projects <- dbGetQuery(con,paste("SELECT lane_1_project,lane_2_project,lane_3_project,lane_4_project,lane_5_project,lane_6_project,lane_7_project,lane_8_project, lane_1_sample, lane_2_sample, lane_3_sample, lane_4_sample, lane_5_sample, lane_6_sample, lane_7_sample, lane_8_sample from flowcell_list WHERE flowcell_id IN (" , flowcellid, " )"))

#todo match also the sample id
samplesheet <- paste("Lane\tArray\tPI\tProj_num\tIndices", sep="")

for(index in c(1:8)){
    sample_desc <- dbGetQuery(con,paste("SELECT label, project_id, index_type, other_variables from sample_list where project_id = ", projects[[index]], " AND sample_id = ", projects[[index+8]], " LIMIT 1", sep=""))
    if(length(sample_desc[[1]])== 0)
        next;
    project_desc <- dbGetQuery(con,paste("SELECT name, pi from project_list where project_id = ", projects[[index]], " LIMIT 1", sep=""))
    a <- strsplit(sample_desc[[4]], '\r\n\r\nIndex type. Designate index sequences (GATTCA, for example): ', fixed=TRUE)[[1]]
    if(! is.na(gsub(" ", "", strsplit(a[2], "\r\n\r\n")[[1]][1])))
        barcodes <- gsub(" ", "", strsplit(a[2], "\r\n\r\n")[[1]][1])
    else if(nchar(sample_desc[[3]]) > 1)
        barcodes <- (gsub(" ", "", sample_desc[[3]]))
    sample_line <- paste("Lane",index,"\t", gsub(" ", "_",sample_desc[[1]]), "\t\"", sapply(project_desc[[1]], toupper),"/PI, ", sapply(project_desc[[2]], toupper),"\"\t", sample_desc[[2]], "\t", "\"", barcodes, "\"",sep="")
    samplesheet <- cbind(samplesheet, sample_line)
}
write(samplesheet, "SampleSheet_DB.csv", sep="")
