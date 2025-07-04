#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr)
library(patchwork)
library(vroom)
library(stringr)

#############################
##### Load count files ######
# Set the directory path
directory_path_counts <- "/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/02_NLRs_TEs/NLRhoods/count_stats"
# List all .tsv files in the directory
tsv_files <- list.files(directory_path_counts, pattern = "\\.tsv$", full.names = TRUE)

# Read .tsv files into a list of data frames
dataframes_counts <- lapply(tsv_files, function(file) {
  read.delim(file, header = TRUE, stringsAsFactors = FALSE, sep = "\t")
})
# Merge data frames based on common columns: "Chr", "Start", "End", "NLR_hood"
Counts_all_merged <- Reduce(function(x, y) merge(x, y, by = c("Chr", "Start", "End", "NLR_hood"), all = TRUE), dataframes_counts)
# Replace NA values with 0 in Counts_all_merged
Counts_all_merged[is.na(Counts_all_merged)] <- 0
##############################
## Load  Methylation files ##
# Set the directory path
directory_path_methylation <- "/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/02_NLRs_TEs/NLRhoods/methylation_stats"
# List all .tsv files in the directory
tsv_files_meth <- list.files(directory_path_methylation, pattern = "\\.tsv$", full.names = TRUE)
# Read .tsv files into a list of data frames
dataframes_methylation <- lapply(tsv_files_meth, function(file) {
  read.delim(file, header = TRUE, stringsAsFactors = FALSE, sep = "\t")
})
# Merge data frames based on common columns: "Chr", "Start", "End", "NLR_hood"
Methylation_all_merged <- Reduce(function(x, y) merge(x, y, by = c("Chr", "Start", "End", "NLR_hood"), all = TRUE), 
                                 dataframes_methylation)
# Replace NA values with 0 in Counts_all_merged
Methylation_all_merged[is.na(Methylation_all_merged )] <- 0

# Create final DF
NLR_NB_hood_stats <-  left_join(Counts_all_merged, Methylation_all_merged, by=c("Chr","Start","End","NLR_hood"))
##############################
## Load  TE count file ##
## calculate entropy ##
# Set the directory path
path_TE_shannon <- "/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/02_NLRs_TEs/NLRhoods/TE_shannon/"
TE_counts_shannon <-  vroom(paste0(path_TE_shannon, "NBhood_TEFAM_counts_Shannon_entropy.tsv"), col_names = TRUE)
TE_shannon <- TE_counts_shannon %>%  group_by(Chr, Start,End,NLR_hood) %>% 
  dplyr::summarize(H = vegan::diversity(TEcount, index = "shannon"))
# Merge dataframes 
NLR_NB_hood_stats <-  left_join(NLR_NB_hood_stats, TE_shannon, by=c("Chr","Start","End","NLR_hood"))

# WRITE FINAL DF
final_path="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/02_NLRs_TEs/NLRhoods/"
write.table(NLR_NB_hood_stats, file = paste0(final_path,"NLR_NB_hood_stats.tsv"), 
            sep = "\t", quote = FALSE, 
            row.names = FALSE)
