

PAF_FILE <- "/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/evaluation_PANGENOME_EDTA/Helitrons/Helitron_PAVs/ALL_SOLO.synteny.paf"
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
  dplyr::mutate(query_genome = str_remove(query_genome, "#.*$"))

# Retrieve Target genome: 
ALL_synteny_paf <-  ALL_synteny_paf %>% dplyr::mutate(target_genome = str_remove(.$tname, "#.*$"))

# Calculate average of gene doblets:

ALL_synteny_paf <- ALL_synteny_paf %>%  dplyr::mutate(avg_upstream_gene=(as.numeric(up_identity)+as.numeric(up_simil))/2)
ALL_synteny_paf <- ALL_synteny_paf %>%  dplyr::mutate(avg_downstream_gene=(as.numeric(dw_identity)+as.numeric(dw_simil))/2)

# Calculate total number of  genomes analized minus one beocause of own  intial query genome. 
Total_number_genomes <-  length(ALL_synteny_paf$target_genome %>%  unique()) - 1 


# Filter by  the filtering_gene_score  to retireve only hits with  `filtering_gene_score` minumn syunteny treeshold. 

ALL_synteny_filtered_paf  <- ALL_synteny_paf %>%  filter(avg_upstream_gene >= filtering_gene_score  && avg_downstream_gene >= filtering_gene_score)



#Tally the filtered  oaf file 

ALL_synteny_filtered_paf_tallied  <- 
  ALL_synteny_filtered_paf %>%  group_by(ID_query, target_genome) %>%  
  tally() %>%  group_by(ID_query)  %>%  tally()



ALL_synteny_filtered_paf_tallied  <- ALL_synteny_filtered_paf_tallied  %>%  
  mutate(PAV_detected = ifelse(n < Total_number_genomes, "PAV", "NOPAV" ))

print(ALL_synteny_filtered_paf_tallied[,c(1,3)])

print(as.data.frame(ALL_synteny_filtered_paf_tallied[,c(1,3)]), row.names=F, n = Inf)

write.table(ALL_synteny_filtered_paf_tallied[,c(1,3)], stdout(), append = FALSE, sep = "\t", dec = ".", quote = FALSE
            row.names = FALSE, col.names = TRUE)