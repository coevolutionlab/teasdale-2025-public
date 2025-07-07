#!/usr/bin/env Rscript 
library(ggplot2)
library(dplyr)
library(patchwork)

args = commandArgs(trailingOnly=TRUE)
# test if there arew all the arguments required
if (length(args)!=4) {
  stop("You need to introduce, in this order: .n 
       1 - Annotation file. .n
       2 - paf file. .n
       3 - filtering gene score (integer: from 1 to 100). .n
       4 - Output name .n", call.=FALSE)
} 

Annotation_file = args[1]
PAF_FILE = args[2]
filtering_gene_score = args[3]
out_name = args[4]


# VARIABLES 

Annotation_file <-  "/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/TE_analisis/fix_TE_search/at6137_intact_noparent.gff3"
PAF_FILE <-  "/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/TE_analisis/fix_TE_search/synteny_analysis_TE/at6137_intacts_all.synteny.paf"
filtering_gene_score=99.9
out_name="at6137_intacts_all_synteny"

Annotation <- vroom(Annotation_file,
                            col_names = FALSE)

# Add TE length
Annotation <-  Annotation %>% dplyr::mutate(length=X5-X4)
#Retrieve method
Annotation <- Annotation  %>%  
  dplyr::mutate(method = str_extract(.$X9, "Method=.*")) %>% 
  dplyr::mutate(method = str_remove(method, ";.*$"))
#Retrieve Classification
Annotation <- Annotation  %>%  
  dplyr::mutate(classification = str_extract(.$X9, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))
#Retrieve Sequence ontology
Annotation <- Annotation  %>%  
  dplyr::mutate(so = str_extract(.$X9, "Sequence_ontology=.*")) %>% 
  dplyr::mutate(so = str_remove(so, ";.*$")) %>% 
  dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
#Retrieve Identity
Annotation <- Annotation  %>%  
  dplyr::mutate(identity = str_extract(.$X9, "Identity=.*")) %>% 
  dplyr::mutate(identity = str_remove(identity, ";.*$")) %>% 
  dplyr::mutate(identity = str_remove(identity, "^Identity="))
#Retrieve TIR
Annotation <- Annotation  %>%  
  dplyr::mutate(tir = str_extract(.$X9, "TIR=.*")) %>% 
  dplyr::mutate(tir = str_remove(tir, ";.*$")) %>% 
  dplyr::mutate(tir = str_remove(tir, "^TIR="))

#Retrieve TSD
Annotation <- Annotation  %>%  
  dplyr::mutate(tsd = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "^TSD="))
#Retrieve TSD score
Annotation <- Annotation  %>%  
  dplyr::mutate(tsd_score = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, "^TSD=.*_"))

#Retrieve TEfam
Annotation <- Annotation  %>%  
  dplyr::mutate(TEfam = str_extract(.$X9, "Name=.*")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, "^Name="))

#Retrieve ID
Annotation <- Annotation  %>%  
  dplyr::mutate(ID = str_extract(.$X9, "ID=.*")) %>% 
  dplyr::mutate(ID = str_remove(ID, ";.*$")) %>% 
  dplyr::mutate(ID = str_remove(ID, "^ID="))


############################

ALL_synteny_paf <-  vroom(PAF_FILE,  col_names = FALSE)
                          
# Retrieve Query TE ID 
ALL_synteny_paf <- ALL_synteny_paf  %>%  
  dplyr::mutate(ID_query = str_remove(.$X1, "::.*$")) %>% 
  dplyr::mutate(ID_query = str_remove(ID_query, "^ID="))

# Retrieve Query genome 
ALL_synteny_paf <-  ALL_synteny_paf %>% 
  dplyr::mutate(query_genome = str_extract(.$X1, "::at.*#")) %>% 
  dplyr::mutate(query_genome = str_remove(query_genome, "^::")) %>% 
  dplyr::mutate(query_genome = str_remove(query_genome, "#$"))

# Retrieve Target genome: 
ALL_synteny_paf <-  ALL_synteny_paf %>% 
  dplyr::mutate(target_genome = str_remove(.$X6, "#.*$"))
  
# Calculate average of gene doblets:

ALL_synteny_paf <- ALL_synteny_paf %>%  dplyr::mutate(avg_upstream_gene=(X14+X15)/2)
ALL_synteny_paf <- ALL_synteny_paf %>%  dplyr::mutate(avg_downstream_gene=(X18+X19)/2)


# Output basic stats:

# Before filtering:

a <- ALL_synteny_paf %>%  ggplot(aes(x=X11)) + 
  geom_histogram() + 
  theme_light() + 
  xlab("TE dissimilarity")

b <- ALL_synteny_paf  %>%  group_by(target_genome) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(target_genome, n), y=n)) + 
  geom_col() + 
  xlab("") + 
  ylab("Number of  hits per genome") + 
  coord_flip() +
  theme_light()

c <- ALL_synteny_paf %>%  ggplot(aes(x=avg_upstream_gene, y= avg_downstream_gene, color=X11)) + 
  geom_point() + 
  xlab("Similarty  of upstream gene") +
  ylab("similarity of downstream gene") + 
  labs(col= "TE dissimilarity") + 
  theme_light()

d <-  ALL_synteny_paf  %>%  group_by(ID_query, target_genome) %>%  
  tally()  %>%  
  ggplot(aes(x=target_genome, y=n)) + 
  geom_jitter(alpha=0.3) + 
  theme_bw() +
  ylab("Number of hits per TE") + 
  xlab("") +
  coord_flip()

raw_plot <- a + b + c + d + plot_annotation( title = 'Synteny based only in "anchor+TE" similarity' ) 

name_first_plot= paste0("raw_output_", out_name, ".pdf")
ggsave(filename = name_first_plot, plot = raw_plot,  width = 20, height = 20, units = "cm")
name_first_plot= paste0("raw_output_", out_name, ".png")
ggsave(filename = name_first_plot, plot = raw_plot,  width = 20, height = 20, units = "cm")

# Perform filtering base on gene: 
 
ALL_synteny_paf_filtered <- ALL_synteny_paf %>%  filter(avg_upstream_gene > filtering_gene_score) %>% 
  filter(avg_downstream_gene > filtering_gene_score)
 
 
a2 <- ALL_synteny_paf_filtered %>%  ggplot(aes(x=X11)) + 
  geom_histogram() + 
  theme_light() + 
  xlab("TE dissimilarity")

b2 <- ALL_synteny_paf_filtered  %>%  group_by(target_genome) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(target_genome, n), y=n)) + 
  geom_col() + 
  xlab("") + 
  ylab("Number of  hits per genome") + 
  coord_flip() +
  theme_light()

c2 <- ALL_synteny_paf_filtered %>%  ggplot(aes(x=avg_upstream_gene, y= avg_downstream_gene, color=X11)) + 
  geom_point() + 
  xlab("Similarty  of upstream gene") +
  ylab("similarity of downstream gene") + 
  labs(col= "TE dissimilarity") + 
  theme_light()

d2 <-  ALL_synteny_paf_filtered  %>%  group_by(ID_query, target_genome) %>%  
  tally()  %>%  
  ggplot(aes(x=target_genome, y=n)) + 
  geom_jitter(alpha=0.3) + 
  theme_bw() +
  ylab("Number of hits per TE") + 
  xlab("") +
  coord_flip()

# Patchwork
title=paste0('Synteny based in "anchor+TE" similarity + local gene similarity > ', filtering_gene_score, "%")
filtered_plot <- a2 + b2 + c2 + d2 + plot_annotation( title = title ) 


# Save it  with ggsave  both pdf and png 
name_filt_plot= paste0("filtered_", filtering_gene_score, "per_", out_name, ".pdf")
ggsave(filename = name_filt_plot, plot = filtered_plot,  width = 20, height = 20, units = "cm")
name_filt_plot= paste0("filtered_", filtering_gene_score, "per_", out_name, ".png")
ggsave(filename = name_filt_plot, plot = filtered_plot,  width = 20, height = 20, units = "cm")


#Nhits_size_summary <- dplyr::inner_join(
##  (ALL_synteny_paf_filtered  %>%  group_by(ID_query, target_genome) %>%  tally()) , 
#  ALL_synteny_paf_filtered[,c(4,20)] , 
#  by="ID_query") %>%  
#  unique()

#MERGE WITH ANNO:

ALL_synteny_paf_merged <- dplyr::inner_join(Annotation, ALL_synteny_paf ,  
                                            by=c("ID" = "ID_query"))

ALL_synteny_paf_merged_filtered <-   ALL_synteny_paf_merged %>%  filter(avg_upstream_gene > filtering_gene_score) %>% 
  filter(avg_downstream_gene > filtering_gene_score)


title <-  paste0(" Syntenic TEs given a local gene identity treshold of > " , filtering_gene_score, "%")
plot_anno_dissim <- ALL_synteny_paf_merged_filtered  %>%  ggplot(aes(x=classification ,y=X11)) + 
  geom_jitter(alpha=0.3) + 
  geom_boxplot(alpha=0.6, color="red") + 
  theme_light() + 
  coord_flip() + 
  ylab("Gap-compressed per-base sequence divergence ") +
  ggtitle(title)

# Save it  with ggsave  both pdf and png 
name_anno_dissim_plot= paste0("filtered_", filtering_gene_score, "per_", out_name, "_divergence_TEs.pdf")
ggsave(filename = name_anno_dissim_plot, plot = plot_anno_dissim,  width = 20, height = 20, units = "cm")
name_anno_dissim_plot= paste0("filtered_", filtering_gene_score, "per_", out_name, "_divergence_TEs.png")
ggsave(filename = name_anno_dissim_plot, plot = plot_anno_dissim,  width = 20, height = 20, units = "cm")



############# Modifiy the filtered, joined,  datafile and output it in a nicer way:

final_data <- ALL_synteny_paf_merged_filtered[,c("classification", "X9.x","length","X6.y", "X8.y", "X9.y", "X11")] 
colnames(final_data) <- c("classification", "TEID", "length", "target_chromosome", "target_start", "target_end", "dissimilarity_score")

data_name= paste0("filtered_", filtering_gene_score, "per_", out_name, "_divergence_TEs.tsv")
write.table(final_data,data_name,sep="\t",row.names=FALSE, quote = FALSE)




