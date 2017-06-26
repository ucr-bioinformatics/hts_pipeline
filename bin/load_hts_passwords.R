#!/usr/bin/env Rscript

pipeline_home <- Sys.getenv('HTS_PIPELINE_HOME')
setwd(pipeline_home)

parsed_passwords <- read.table(file = 'passwords-decrypted.tsv', sep = '\t', header = TRUE)

# Set 
hts_pass <- list()
hts_pass$db <-unlist(subset(parsed_passwords, purpose == 'db'))

