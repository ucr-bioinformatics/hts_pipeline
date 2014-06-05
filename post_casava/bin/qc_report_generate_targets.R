#!/usr/bin/env Rscript

### Generate FASTQ Quality report in PDF format
## Neerja Katiyar
## 2/4/2014

# Get script arguments
args <- commandArgs(trailingOnly = TRUE)
#args <- c(221,2,'/shared/genomics/221/','/bigdata/nkatiyar/QC_flowcells/221/')
if (length(args) < 5) {
    stop("USAGE:: script.R <FlowcellID> <NumberOfPairs> <FASTQPath> <TargetsPath> <SampleSheetPath> <Demultiplex type>")
}
flowcellid <- args[1]
num_pairs <- args[2]
fastq_path <- args[3]
targets_path <- args[4]
samplesheet <- read.csv(args[5])
demultiplex_type <- args[6]
#run_type <- args[6]

# Pull Girke Code
source("http://faculty.ucr.edu/~tgirke/Documents/R_BioCond/My_R_Scripts/fastqQuality.R")

project_id <- samplesheet$SampleProject
sample_id <- samplesheet$SampleID
print("sample_id")
print(sample_id)
lane_samplesheet <- samplesheet$Lane
print("lane_samplesheet")
print(lane_samplesheet)
index <- samplesheet$Index
chk <- unlist(lane_samplesheet)
print(chk)
print(".........")
uniq_lane_list <- unique(unlist(lane_samplesheet))
print("uniq_lane_list")
print(uniq_lane_list)
cnt=1
for(lane in uniq_lane_list) {
	print("lane")
	print(lane)
	targets_filename <-c(paste(targets_path,"targets_lane",lane,".txt",sep=""))	
	file_list <- c()
	samp_list <- c()
	file_list1 <- c()
	file_list2 <- c()
	file_list3 <- c()
	sample_num=1
	samp_path <- c(paste("/shared/genomics/",flowcellid,"/",sep=""))
        pattern_f <- c(paste("^flowcell",flowcellid,"_","lane",lane,"_",'*',sep=""))
	print(pattern_f)
	samp_file_list <- list.files(path=samp_path, pattern=pattern_f)
	targets_filename <-c(paste(targets_path,"targets_lane",lane,".txt",sep=""))
	print(length(samp_file_list))
	
	if(num_pairs==1)
	{
		for (f in 1:length(samp_file_list))
		{
			if(demultiplex_type==2)
			{
				#index[cnt]=""
				pattern_file1 <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair1","_R1.fastq.gz",sep=""))
				pattern_file2 <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair2","_R2.fastq.gz",sep=""))
				print(pattern_file1)
				file_list1 <- append(file_list1, pattern_file1)
                		file_list2 <- append(file_list2, pattern_file2)
                		sample_name <- paste("Sample",sample_num,sep="")
                		samp_list <- append(samp_list,sample_name)
                		sample_num=sample_num+1
                		cnt=cnt+1
			}		
			else
			{	
				concat="_"
				pattern_file <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair1",concat,index[cnt],".fastq.gz",sep=""))
				file_list <- append(file_list, pattern_file)
				sample_name <- paste("Sample",sample_num,sep="")
				samp_list <- append(samp_list,sample_name)
				sample_num=sample_num+1
				cnt=cnt+1
			}
		}		
		if(demultiplex_type==2)	
		{	
			print(samp_list)
        		list_out <- cbind(FileName1=file_list1, FileName2=file_list2, SampleName=samp_list)
        		print("list_out")
			print(list_out)
			write.table(list_out,targets_filename, quote=FALSE, row.names=FALSE, sep="\t")
		}	
		else
		{
			print(samp_list)
			list_out <- cbind(FileName1=file_list, SampleName=samp_list)
			write.table(list_out,targets_filename, quote=FALSE, row.names=FALSE, sep="\t")	
		}	
	}
        if(num_pairs==2)
        {
		for (f in 1:(length(samp_file_list)/2))
                {
			if(demultiplex_type==2)
                	{
                 		index[cnt]=""
				concat=""
				pattern_file1 <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair1",concat,index[cnt],".fastq.gz",sep=""))
	                	pattern_file2 <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair2",concat,index[cnt],".fastq.gz",sep=""))
        	        	pattern_file3 <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair3",concat,index[cnt],".fastq.gz",sep=""))
				file_list1 <- append(file_list1, pattern_file1)
                		file_list2 <- append(file_list2, pattern_file2)
				file_list3 <- append(file_list3, pattern_file3)
               			sample_name <- paste("Sample",sample_num,sep="")
                		samp_list <- append(samp_list,sample_name)
                		sample_num=sample_num+1
                		cnt=cnt+1
                	}	
                	else
                	{	
                        	concat="_"
                		pattern_file1 <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair1",concat,index[cnt],".fastq.gz",sep=""))
                		pattern_file2 <- c(paste("flowcell",flowcellid,"_","lane",lane,"_","pair2",concat,index[cnt],".fastq.gz",sep="")) 
				file_list1 <- append(file_list1, pattern_file1)
				file_list2 <- append(file_list2, pattern_file2)
                		sample_name <- paste("Sample",sample_num,sep="")
                		samp_list <- append(samp_list,sample_name)
				sample_num=sample_num+1
                		cnt=cnt+1
			}	
		}
		if(demultiplex_type==2)
		{		
			print(samp_list)
        		list_out <- cbind(FileName1=file_list1, FileName2=file_list2, FileName3=file_list3)
        		list_out <- cbind(list_out, SampleName=samp_list)
			write.table(list_out,targets_filename, quote=FALSE, row.names=FALSE, sep="\t")
        	}
		else
		{
			print(samp_list)
        		list_out <- cbind(FileName1=file_list1, FileName2=file_list2)
        		list_out <- cbind(list_out, SampleName=samp_list)
        		write.table(list_out,targets_filename, quote=FALSE, row.names=FALSE, sep="\t")
		}
	}
}

# For each lane target file, process PDF report
#for (lane in uniq_lane_list) {
for (lane in uniq_lane_list) {
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
	if(demultiplex_type == 1 )
	{
        	myfiles <- paste(fastq_path, targets$FileName1, sep="")
        	names(myfiles) <- targets$SampleName
		# What files are we processing
        	print("Printing myfiles...")
        	print(myfiles)
        	print("Generating report now")
    		# Generate PDF Report
    		fqlist <- seeFastq(fastq=myfiles, batchsize=50000, klength=8)
    	}
	else
	{
		myfiles1 <- paste(fastq_path, targets$FileName1, sep="")
	        names(myfiles1) <-paste(targets$SampleName, "_pair1", sep="")
        	myfiles2 <- paste(fastq_path, targets$FileName2, sep="")
        	names(myfiles2) <-paste(targets$SampleName, "_pair2", sep="")
        	myfiles <- append(myfiles1, myfiles2)
		# What files are we processing
        	print("Printing myfiles...")
        	print(myfiles)
        	print("Generating report now")
    		# Generate PDF Report
    		fqlist <- seeFastq(fastq=myfiles, batchsize=50000, klength=2)
	}
	 		}
     else if (num_pairs == 2) {
	if(demultiplex_type == 1 )
        {
        	myfiles1 <- paste(fastq_path, targets$FileName1, sep="")
        	names(myfiles1) <-paste(targets$SampleName, "_pair1", sep="")
        	myfiles2 <- paste(fastq_path, targets$FileName2, sep="")
        	names(myfiles2) <-paste(targets$SampleName, "_pair2", sep="")
        	myfiles <- append(myfiles1, myfiles2)
		# What files are we processing
       		print("Printing myfiles...")
        	print(myfiles)
        	print("Generating report now")
    		# Generate PDF Report
    		fqlist <- seeFastq(fastq=myfiles, batchsize=50000, klength=8)
    	}
	else
	{
		myfiles1 <- paste(fastq_path, targets$FileName1, sep="")
                names(myfiles1) <-paste(targets$SampleName, "_pair1", sep="")
                myfiles2 <- paste(fastq_path, targets$FileName2, sep="")
                names(myfiles2) <-paste(targets$SampleName, "_pair2", sep="")
                myfiles3 <- paste(fastq_path, targets$FileName3, sep="")
                names(myfiles3) <-paste(targets$SampleName, "_pair3", sep="")
		myfiles <- append(myfiles1, myfiles2, myfiles3)
		# What files are we processing
        	print("Printing myfiles...")
        	print(myfiles)
        	print("Generating report now")
    		# Generate PDF Report
    		fqlist <- seeFastq(fastq=myfiles, batchsize=50000, klength=8)
	}
#    else {
#        stop(paste("ERROR::", num_pairs, "pairs not supported."))
    }
    file_name <- paste("flowcell", flowcellid, "_lane", lane, "_fastqReport.pdf", sep="")
    print("Printing report names")
    print(file_name)
    pdf(file_name, height=18, width=8*length(myfiles))
    seeFastqPlot(fqlist)
    dev.off()
}
warnings()

