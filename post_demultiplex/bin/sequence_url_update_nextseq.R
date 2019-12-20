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
qcs <- list.files(path='.',pattern='qc[1-9]*')
#pairs=0   

# Load password info
hts_pipeline_home <- Sys.getenv("HTS_PIPELINE_HOME")
source(paste(hts_pipeline_home, "/bin/load_hts_passwords.R", sep = ""))

# Connect to Database
require(RMySQL, quietly = TRUE)
con <- dbConnect(MySQL(), user=hts_pass$db['user'], password=hts_pass$db['pass'],dbname="projects", host="penguin", port=3611)

# Get sample and project ids
flowcell_table <- dbGetQuery(con,paste("SELECT * FROM flowcell_list where flowcell_id = ", flowcellid," LIMIT 1",sep=""))

sequence_url <-paste( "/illumina_runs/",flowcellid, "/", sep="")

# Check if Bustard Summary exists for each 'qc' sym-link
qc_url <- c()
if (length(qcs) > 0) {
    for (qc in qcs){
        qc_url <- cbind(qc_url, paste(sequence_url, qc, sep="") )
    }
    qc_url <- paste(qc_url,collapse="\n")
}

# Update CASAVA Bustard Summary in flowcell_list table
command <-paste("UPDATE `flowcell_list` SET `qc_url` = '", qc_url, "' WHERE `flowcell_id` =", flowcellid, " LIMIT 1",sep="")
result <- dbGetQuery(con,command)
writeLines(paste("QC_URL:: \n",qc_url))

fastq_files_list=list()
qual_url_list=list()

# Update sequence_url and quality_url in sample_list table
for (i in c(1:lanes)) {
    control <-  flowcell_table[paste("lane_",i,"_control",sep="")][[1]]

    if (control==0) {
         # if (pairs==0) { 
	 fastqfiles <- list.files(paste(fastq_path,"/",sep=""), paste("lane",i,sep=""))
     fastq_files_list <- append(fastq_files_list, fastqfiles) 

        # Build fastq URLs
	fastqurl <- paste(sequence_url, fastq_files_list,sep="")
	fastqurl <- paste(fastqurl, collapse="\n")

        # Build CASAVA Demultiplex URLs for each 'qc' directory
        quality_url <- c()
        for (qc in qcs){
            quality_url <- cbind(quality_url, paste(sequence_url,qc,"/",sep="")) 
        }

        # Define FASTQ Qualtiy Report PDF path
	fq_pdf_report <- paste("fastq_report/flowcell",flowcellid,"_lane",i,"_fastqReport.pdf",sep="")
	# Check if FASTQ Quality Report PDF exists
	if(file.exists(fq_pdf_report)){
            qual_url <- paste(sequence_url, fq_pdf_report, sep="")
            qual_url <- cbind(qual_url, quality_url)
            qual_url_list <- append(qual_url_list, qual_url) 
            # Flatten URLs to a string
            qual_url_list <- paste(qual_url_list, collapse="\n")
        } else {
            qual_url_list <- ""
        }
	qual_url <-c(qual_url_list,qc_url)    
    }
}

i=1
project_id <- flowcell_table[paste("lane_",i,"_project",sep="")][[1]]
sample_id <- flowcell_table[paste("lane_",i,"_sample",sep="")][[1]]

command <- paste("UPDATE `sample_list` SET `sequence_url` = '", fastqurl,"',`quality_url` = '", qual_url, "' WHERE `sample_list`.`sample_id` =", sample_id, " AND `sample_list`.`project_id` =", project_id, " LIMIT 1",sep="")
print(command)

dbGetQuery(con,command)
writeLines(paste("Updated FASTQs:: \n",fastqurl))
writeLines(paste("QUAL_URL:: \n",qual_url))

# Update status of flowcell to pipeline completed
command <- paste("UPDATE `projects`.`flowcell_list` SET `status` = 'pipeline completed' WHERE `flowcell_list`.`flowcell_id` =", flowcellid, " LIMIT 1",sep="")
result <- dbGetQuery(con,command)

# Disconnect from Database
#dbClearResult(dbListResults(con)[[1]])
dis <- dbDisconnect(con)

# Exit program
quit()
