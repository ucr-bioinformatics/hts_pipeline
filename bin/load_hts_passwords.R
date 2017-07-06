#!/usr/bin/env Rscript

# Store current working directory to be restored after script
old_wd <- getwd()

pipeline_home <- Sys.getenv('HTS_PIPELINE_HOME')
setwd(pipeline_home)

system('gpg --output passwords-decrypted.tsv --decrypt passwords.tsv.gpg')

parsed_passwords <- read.table(file = 'passwords-decrypted.tsv', sep = '\t', header = TRUE)

# Set 
hts_pass <- list()
hts_pass$db <- unlist(subset(parsed_passwords, purpose == 'db'))
hts_pass$db <- sapply(hts_pass$db, as.character)
names(hts_pass$db) <- names(parsed_passwords)

file.remove('passwords-decrypted.tsv')
setwd(old_wd)
