#!/usr/bin/env Rscript

### Update the URL of HT sequence website 
## Author Ruobai Sun
## Last modify 6/4/2013

# Get script arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
    stop("USAGE:: script.R <FlowcellID> <NumberOfLanes> <FASTQPath>")
}
flowcellid <- args[1]
lanes <- args[2]
fastq_path <- args[3]
setwd(fastq_path)
qcs <- list.files(path='.',pattern='^qc[1-9]*')
#pairs=0   

# Connect to Database
require(RMySQL, quietly = TRUE)
con <- dbConnect(MySQL(), user="webuser", password="5any77z1",dbname="projects", host="illumina.int.bioinfo.ucr.edu")

# Get sample and project ids
flowcell_table <- dbGetQuery(con,paste("SELECT * FROM flowcell_list where flowcell_id = ", flowcellid," LIMIT 1",sep=""))

sequence_url <-paste( "/illumina_runs/",flowcellid, "/", sep="")

# Check if Bustard Summary exists for each 'qc' sym-link
qc_url <- c()
if (length(qcs) > 0) {
    for (qc in qcs){
        qc_url <- cbind(qc_url, paste(sequence_url, qc, "/",sep="") )
    }
    qc_url <- paste(qc_url,collapse="\n")
}

# Update CASAVA Bustard Summary in flowcell_list table
command <-paste("UPDATE `flowcell_list` SET `qc_url` = '", qc_url, "' WHERE `flowcell_id` =", flowcellid, " LIMIT 1",sep="")
result <- dbGetQuery(con,command)
writeLines(paste("QC_URL:: \n",qc_url))

# Update sequence_url and quality_url in sample_list table
for (i in c(1:lanes)) {
    project_id <- flowcell_table[paste("lane_",i,"_project",sep="")][[1]]
    sample_id <- flowcell_table[paste("lane_",i,"_sample",sep="")][[1]]
    #flowcellid <- dbGetQuery(con,paste("SELECT flowcell_id from flowcell_list WHERE ",project_id," IN (lane_1_project,lane_2_project,lane_3_project,lane_4_project,lane_5_project,lane_6_project,lane_7_project,lane_8_project)"))[[1]]
    control <-  flowcell_table[paste("lane_",i,"_control",sep="")][[1]]

    if (control==0) {
        fastqfiles <- list.files(paste(fastq_path,"/",sep=""), paste("lane",i,sep=""))
        print(fastqfiles)

        # Build fastq URLs
        fastqurl <- paste(sequence_url, fastqfiles,sep="")
        fastqurl <- paste(fastqurl, collapse="\n")

        # Build CASAVA Demultiplex URLs for each 'qc' directory
        quality_url <- c()
        for (qc in qcs){
            quality_url <- cbind(quality_url, paste(sequence_url,qc,"/",sep=""))
            qc_url <- cbind(quality_url, paste(sequence_url,qc,"/",sep="")) 
        }

        # Define FASTQ Qualtiy Report PDF path
        fq_pdf_report <- paste("fastq_report/flowcell",flowcellid,"_lane",i,"_fastqReport.pdf",sep="")
        # Check if FASTQ Quality Report PDF exists
        if(file.exists(fq_pdf_report)){
            qual_url <- paste(sequence_url, fq_pdf_report, sep="")
            qual_url <- cbind(qual_url, quality_url)
            #ask about this
            #dir_url <- paste( "http://illumina.bioinfo.ucr.edu/illumina_runs/",flowcellid, "/fastq_report/", sep="")
            #qual_url <- cbind(qual_url, dir_url)
           
            # Flatten URLs to a string
            qual_url <- paste(qual_url, collapse="\n")
        } else {
            qual_url <- ""
        }
        qual_url <-c(qual_url,qc_url)

        command <- paste("UPDATE `sample_list` SET `sequence_url` = '", fastqurl,"',`quality_url` = '", qual_url, "' WHERE `sample_list`.`sample_id` =", sample_id, " AND `sample_list`.`project_id` =", project_id, " LIMIT 1",sep="")
        dbGetQuery(con,command)
        writeLines(paste("Updated FASTQs:: \n",fastqurl))
        writeLines(paste("QUAL_URL:: \n",qual_url))
    }
}


# Update status of flowcell to pipeline completed
command <- paste("UPDATE `projects`.`flowcell_list` SET `status` = 'pipeline completed' WHERE `flowcell_list`.`flowcell_id` =", flowcellid, " LIMIT 1",sep="")
result <- dbGetQuery(con,command)

# Disconnect from Database
#dbClearResult(dbListResults(con)[[1]])
dis <- dbDisconnect(con)

# Exit program
quit()
