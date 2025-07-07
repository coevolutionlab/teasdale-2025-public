#!/usr/bin/env Rscript 
library(ggplot2)
library(dplyr)
library(patchwork)
library(vroom)
library(stringr)

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
out_name = args[4]


# VARIABLES 


PAF_FILE <-  "/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/TE_analisis/syntenic_genes/at6137_gene_annotation_chrom_only_augustus-v2_all.synteny.paf"
filtering_gene_score=90
#out_name="at6137_genic_synteny"


############################

ALL_synteny_paf <-  vroom(PAF_FILE,  col_names = TRUE)

                                       
# Retrieve Query TE ID 
ALL_synteny_paf <- ALL_synteny_paf  %>%  
  dplyr::mutate(ID_query = str_remove(.$qname, "::.*$")) %>% 
  dplyr::mutate(ID_query = str_remove(ID_query, "^ID="))

# Retrieve Query genome 
ALL_synteny_paf <-  ALL_synteny_paf %>% 
  dplyr::mutate(query_genome = str_extract(.$qname, "::at.*#")) %>% 
  dplyr::mutate(query_genome = str_remove(query_genome, "^::")) %>% 
  dplyr::mutate(query_genome = str_remove(query_genome, "#$"))

# Retrieve Target genome: 
ALL_synteny_paf <-  ALL_synteny_paf %>% 
  dplyr::mutate(target_genome = str_remove(.$tname, "#.*$"))

# Calculate average of gene doblets:

ALL_synteny_paf <- ALL_synteny_paf %>%  dplyr::mutate(avg_upstream_gene=(as.numeric(up_identity)+as.numeric(up_simil))/2)
ALL_synteny_paf <- ALL_synteny_paf %>%  dplyr::mutate(avg_downstream_gene=(as.numeric(dw_identity)+as.numeric(dw_simil))/2)


# Output basic stats:

# Before filtering:

a <- ALL_synteny_paf %>%  ggplot(aes(x=X11)) + 
  geom_histogram() + 
  theme_light() + 
  xlab("Query dissimilarity")

b <- ALL_synteny_paf  %>%  group_by(target_genome) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(target_genome, n), y=n)) + 
  geom_col() + 
  xlab("") + 
  ylab("Number of hits per genome") + 
  coord_flip() +
  theme_light()

c <- ALL_synteny_paf %>%  ggplot(aes(x=avg_upstream_gene, y= avg_downstream_gene, color=div_score)) + 
  geom_point() + 
  xlab("Similarty of upstream gene") +
  ylab("similarity of downstream gene") + 
  labs(col= "Query dissimilarity") + 
  theme_light()

d <-  ALL_synteny_paf  %>%  group_by(ID_query, target_genome) %>%  
  tally()  %>%  
  ggplot(aes(x=target_genome, y=n)) + 
  geom_jitter(alpha=0.3) + 
  theme_bw() +
  ylab("Number of hits per query") + 
  xlab("") +
  coord_flip()

raw_plot_1 <- a + b + c + d + plot_annotation( title = 'Synteny based only in "anchor+query" similarity' ) 


# Perform filtering base on gene: 

ALL_synteny_paf_filtered <- ALL_synteny_paf %>%  filter(avg_upstream_gene > filtering_gene_score) %>% 
  filter(avg_downstream_gene > filtering_gene_score)


a2 <- ALL_synteny_paf_filtered %>%  ggplot(aes(x=div_score)) + 
  geom_histogram() + 
  theme_light() + 
  xlab("Query dissimilarity")

b2 <- ALL_synteny_paf_filtered  %>%  group_by(target_genome) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(target_genome, n), y=n)) + 
  geom_col() + 
  xlab("") + 
  ylab("Number of  hits per genome") + 
  coord_flip() +
  theme_light()

c2 <- ALL_synteny_paf %>%  ggplot(aes(x=avg_upstream_gene, y= avg_downstream_gene, color=div_score)) + 
  geom_point() + 
  xlab("Similarty of upstream gene") +
  ylab("similarity of downstream gene") + 
  labs(col= "Query dissimilarity") + 
  theme_light()

d2 <-  ALL_synteny_paf_filtered  %>%  group_by(ID_query, target_genome) %>%  
  tally()  %>%  
  ggplot(aes(x=target_genome, y=n)) + 
  geom_jitter(alpha=0.3) + 
  theme_bw() +
  ylab("Number of hits per query") + 
  xlab("") +
  coord_flip()

ALL_synteny_paf_filtered %>%  
  ggplot(aes(x=(u_gene_dis_query - u_gene_dis_candidate), 
              y=(d_gene_dis_query - d_gene_dis_candidate), 
             color=div_score)) + 
  geom_point()


# Patchwork
title=paste0('Synteny based in query hit similarity + local gene similarity > ', filtering_gene_score, "%")
filtered_plot_2 <- a2 + b2 + c2 + d2 + plot_annotation( title = title ) 



# FILTER BY NLRs:
gene_list <- read.table("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/TE_analisis/NLR_clusters/at6137_NLRS.txt", 
                                        quote="\"", comment.char="")
colnames(gene_list) <- c("ID_query")


ALL_synteny_paf_NLRs  <- dplyr::left_join(gene_list, ALL_synteny_paf ,  by="ID_query")

ALL_synteny_paf_NLRs %>%  
  ggplot(aes(y=(u_gene_dis_query - u_gene_dis_candidate), 
             x=(d_gene_dis_query - d_gene_dis_candidate), 
             color=div_score)) +
  ylab("Distance difference upstream (Query-Target)") +
  xlab("Distance difference downstream (Query-Target)") +
  geom_point() +
  theme_light()



a3 <-ALL_synteny_paf_NLRs  %>%  ggplot(aes(x=div_score)) + 
  geom_histogram() + 
  theme_light() + 
  xlab("Query dissimilarity")

b3 <- ALL_synteny_paf_NLRs   %>%  group_by(target_genome) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(target_genome, n), y=n)) + 
  geom_col() + 
  xlab("") + 
  ylab("Number of  hits per genome") + 
  coord_flip() +
  theme_light()

c3 <- ALL_synteny_paf_NLRs  %>%  ggplot(aes(x=avg_upstream_gene, y= avg_downstream_gene, color=div_score)) + 
  geom_point() + 
  xlab("Similarty of upstream gene") +
  ylab("similarity of downstream gene") + 
  labs(col= "Query dissimilarity") + 
  theme_light()

d3 <-  ALL_synteny_paf_NLRs   %>%  group_by(ID_query, target_genome) %>%  
  tally()  %>%  
  ggplot(aes(x=target_genome, y=n)) + 
  geom_jitter(alpha=0.3) + 
  theme_bw() +
  ylab("Number of hits per query") + 
  xlab("") +
  coord_flip()

e3 <- ALL_synteny_paf_NLRs  %>%  
  ggplot(aes(y=(u_gene_dis_query - u_gene_dis_candidate), 
             x=(d_gene_dis_query - d_gene_dis_candidate), color="grey40")) +
  ylab("Distance difference upstream (Query-Target)") +
  xlab("Distance difference downstream (Query-Target)") +
  geom_point(color="grey40", alpha=0.7) +
  theme_light()

# Patchwork
title=paste0('NLR synteny based in query hit similarity' )
raw_plot_2 <- ((a3 + b3 + c3 + d3) + e3) + plot_annotation( title = title ) 

# FITLER NLRS BY  PROT

ALL_synteny_paf_NLRs_filtered <-  ALL_synteny_paf_NLRs   %>%  filter(avg_upstream_gene > filtering_gene_score) %>% 
  filter(avg_downstream_gene > filtering_gene_score)

a4 <- ALL_synteny_paf_NLRs_filtered %>%  ggplot(aes(x=div_score)) + 
  geom_histogram() + 
  theme_light() + 
  xlab("Query dissimilarity")
b4 <- ALL_synteny_paf_NLRs_filtered  %>%  group_by(target_genome) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(target_genome, n), y=n)) + 
  geom_col() + 
  xlab("") + 
  ylab("Number of  hits per genome") + 
  coord_flip() +
  theme_light()
c4 <- ALL_synteny_paf_NLRs_filtered %>%  ggplot(aes(x=avg_upstream_gene, y= avg_downstream_gene, color=div_score)) + 
  geom_point() + 
  xlab("Similarty of upstream gene") +
  ylab("similarity of downstream gene") + 
  labs(col= "Query dissimilarity") + 
  theme_light()
d4 <- ALL_synteny_paf_NLRs_filtered %>%  group_by(ID_query, target_genome) %>%  
  tally()  %>%  
  ggplot(aes(x=target_genome, y=n)) + 
  geom_point(alpha=0.3) + 
  theme_bw() +
  ylab("Number of hits per query") + 
  xlab("") +
  coord_flip()

e4 <- ALL_synteny_paf_NLRs_filtered %>%  
  ggplot(aes(y=(u_gene_dis_query - u_gene_dis_candidate), 
             x=(d_gene_dis_query - d_gene_dis_candidate), color="grey40")) +
  ylab("Distance difference upstream (Query-Target)") +
  xlab("Distance difference downstream (Query-Target)") +
  geom_point(color="grey40", alpha=0.7) +
  theme_light()



# Patchwork
title=paste0('NLR synteny based in query hit similarity + local gene similarity > ', filtering_gene_score, "%")
filtered_plot_4 <- (a4 + b4 + c4 + d4 + e4) + plot_annotation( title = title ) 



# FITLER BY PROT AND DISTANCE
  
distance_tresh <- 1000 
ALL_synteny_paf_NLRs_filtered_distance <- ALL_synteny_paf_NLRs %>%  filter(avg_upstream_gene > filtering_gene_score) %>% 
  filter(avg_downstream_gene > filtering_gene_score) %>%  
  filter( abs((u_gene_dis_query - u_gene_dis_candidate)) < distance_tresh) %>% 
  filter( abs((d_gene_dis_query - d_gene_dis_candidate)) < distance_tresh)


a5 <- ALL_synteny_paf_NLRs_filtered_distance %>%  ggplot(aes(x=div_score)) + 
  geom_histogram() + 
  theme_light() + 
  xlab("Query dissimilarity")
b5 <- ALL_synteny_paf_NLRs_filtered_distance  %>%  group_by(target_genome) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(target_genome, n), y=n)) + 
  geom_col() + 
  xlab("") + 
  ylab("Number of  hits per genome") + 
  coord_flip() +
  theme_light()
c5 <- ALL_synteny_paf_NLRs_filtered_distance %>%  ggplot(aes(x=avg_upstream_gene, y= avg_downstream_gene, color=div_score)) + 
  geom_point() + 
  xlab("Similarty of upstream gene") +
  ylab("similarity of downstream gene") + 
  labs(col= "Query dissimilarity") + 
  theme_light()
d5 <- ALL_synteny_paf_NLRs_filtered_distance %>%  group_by(ID_query, target_genome) %>%  
  tally()  %>%  
  ggplot(aes(x=target_genome, y=n)) + 
  geom_point(alpha=0.3) + 
  theme_bw() +
  ylab("Number of hits per query") + 
  xlab("") +
  coord_flip()

e5 <- ALL_synteny_paf_NLRs_filtered_distance %>%  
  ggplot(aes(y=(u_gene_dis_query - u_gene_dis_candidate), 
             x=(d_gene_dis_query - d_gene_dis_candidate), color="grey40")) +
  ylab("Distance difference upstream (Query-Target)") +
  xlab("Distance difference downstream (Query-Target)") +
  geom_point(color="grey40", alpha=0.7) +
  theme_light()

# Patchwork
title=paste0('NLR synteny based in query hit similarity + local gene similarity > ', filtering_gene_score, "%", " + max distance ", distance_tresh, "bp.")
filtered_plot_5 <- (a5 + b5 + c5 + d5 + e5) + plot_annotation( title = title ) 
