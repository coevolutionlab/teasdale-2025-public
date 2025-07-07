#!/usr/bin/env Rscript
# This script calculates LTR ages from the alignments produced by ltr_age_intacts.sh

#Install required packages
#install.packages("ape")
#install.packages("tidyverse")
#install.packages("optparse")


#Load the libraries
library(ape)
library(tidyverse)
library(optparse)

arg_parser <- OptionParser()
arg_parser <- OptionParser(usage = "Usage: Rscript script.R [options]")

# Define the options
arg_parser <- add_option("-p", "--path", dest = "path", help = "Path to LTR alignments")
arg_parser <- add_option("-o", "--output", dest = "output", help = "Output file name")

# Parse the command-line arguments
options <- parse_args(arg_parser)

# Extract the values
ltr_path <- getOption("path")
output_file <- getOption("output")

# Check if both arguments are provided
if (is.null(ltr_path) || is.null(output_file)) {
  stop("Please provide both the LTR alignments path and the output file name.")
}



# Mutation rate used 
mutation_rate=7*1E-9 # Ossowski et al 2014. 

filenames=list.files(ltr_path, pattern='.aln')

# Create DF
ltr_ages=data.frame(TEname=str_split_fixed(filenames, '\\.', 3)[,1])
ltr_ages$k2p=NA
ltr_ages$raw=NA
ltr_ages$tn93=NA
########

#load the aligments and use the package ape to calculate the distance
# Include it in the age df 
for (i in 1:length(filenames)){
    ltr=read.FASTA(paste0(ltr_path,filenames[i]))
    if( !is.null(ltr) && length(ltr) > 1  ){
      d=ape::dist.dna(ltr, model='K80', variance = TRUE)
      ltr_ages$k2p[i]=d
      raw=dist.dna(ltr, model='raw', variance = TRUE)
      ltr_ages$raw[i]=raw
      tn93=dist.dna(ltr, model='tn93', variance = TRUE)
      ltr_ages$tn93[i]=tn93
    }
  }


ltr_ages$mya_k2p=ltr_ages$k2p/(2*mutation_rate)/1E6
ltr_ages$mya_raw=ltr_ages$raw/(2*mutation_rate)/1E6
ltr_ages$mya_tn93=ltr_ages$tn93/(2*mutation_rate/1E6)

# Convert to tibble
ltr_ages <- as_tibble(ltr_ages) %>%  mutate(ID = str_remove(TEname,"ltr_")) %>%  select(-TEname)
# Write  it to disk
write.table(ltr_ages,
            file = output_file, 
            sep = "\t",
            quote = FALSE,
            row.names = FALSE,
            col.names = TRUE)
