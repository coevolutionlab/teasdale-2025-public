


ALL_overlaps <- vroom("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/FINAL_TE_annotation/TE_analisis/chimeric_TEs/ALL_overlaps_300bp_IsoSeq_TEanno.tsv.gz",
                      col_names = c("accession", "chrom_read" , "start_read", "end_read", "sequence_ID", "qual_read", "strand_read",
                                    "chrom_TE", "source", "feature", "start_TE", "end_TE","score_TE", "strand_TE",  "phase_TE", "atributes_TE",
                                    "overlap_bp"))

# Add Info colum,nsd bassed on the attribute of the TEaqnno GFF 

# Add TE length
  ALL_overlaps <-  ALL_overlaps %>% dplyr::mutate(length_TE=end_TE-start_TE)
#Retrieve method
ALL_overlaps <- ALL_overlaps  %>%  
  dplyr::mutate(method = str_extract(.$atributes_TE, "Method=.*")) %>% 
  dplyr::mutate(method = str_remove(method, ";.*$"))
#Retrieve Classification
ALL_overlaps <- ALL_overlaps  %>%  
  dplyr::mutate(classification = str_extract(.$atributes_TE, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))
#Retrieve Sequence ontology
ALL_overlaps <- ALL_overlaps  %>%  
  dplyr::mutate(so = str_extract(.$atributes_TE, "Sequence_ontology=.*")) %>% 
  dplyr::mutate(so = str_remove(so, ";.*$")) %>% 
  dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
#Retrieve Identity
ALL_overlaps <- ALL_overlaps  %>%  
  dplyr::mutate(identity = str_extract(.$atributes_TE, "Identity=.*")) %>% 
  dplyr::mutate(identity = str_remove(identity, ";.*$")) %>% 
  dplyr::mutate(identity = str_remove(identity, "^Identity="))
#Retrieve TEfam
ALL_overlaps <- ALL_overlaps  %>%  
  dplyr::mutate(TEfam = str_extract(.$atributes_TE, "Name=.*")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, "^Name="))
#Retrieve ID
ALL_overlaps <- ALL_overlaps  %>%  
  dplyr::mutate(TEID = str_extract(.$atributes_TE, "ID=.*")) %>% 
  dplyr::mutate(TEID = str_remove(TEID, ";.*$")) %>% 
  dplyr::mutate(TEID = str_remove(TEID, "^ID="))
#Retrieve  de novos/Tair10
ALL_overlaps <- ALL_overlaps  %>%  
  dplyr::mutate( Annotation= ifelse(grepl("AT.*", TEfam), "TAIR10", "DENOVO"))

#Retrieve overlap perc
ALL_overlaps <- ALL_overlaps  %>% 
  mutate(perc_overlap = (overlap_bp-1)/length_TE)

ALL_overlaps <-  ALL_overlaps[,-c(6,7,9,14,15)]

########################################################
########################################################
# Fitler  wrong TE famlies:
badTE_list <-  c("TE_00000348")
ALL_overlaps <- ALL_overlaps  %>%  filter(!TEfam %in% badTE_list)
ALL_overlaps  %>%  
  ggplot(aes(x=length_TE)) + 
  geom_histogram(bins=1000) + 
  theme_light() + 
  xlab("Overlap in bp")

ALL_overlaps  %>%  
  ggplot(aes(x=perc_overlap, y=length_TE)) + 
  geom_point(alpha = 0.3, color="grey40") + 
  theme_light() + 
  xlab("perc overlap between TEs and reads")

ALL_overlaps %>% mutate(overlap_bp_bins = cut(X17, seq(min(ALL_overlaps$length_TE), max(ALL_overlaps$length_TE), 100))) %>% 
  filter( overlap_bp_bins   = "(301,401]")

####################

plot_list_class <- list()
plot_list_fams <- list()
plot_list_st <- list()
total <- ALL_overlaps  %>% nrow()
thresholds <- seq(300,2000,300)

for(i in 1:length(thresholds)){
numb <- ALL_overlaps %>% filter(X17 >= thresholds[i] ) %>%  nrow()
title <- paste0("> ", thresholds[i], "bp overlap")
subtitle <-  paste0(round((numb/total), digits = 2), "% reads retrieved")
p <- ALL_overlaps  %>%
  filter(X17 >= thresholds[i] )  %>% 
  group_by(classification) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(classification,n),y=n/10^6)) + 
     geom_col() +
     theme_light(base_size = 12) + 
     coord_flip() +
     xlab("") +
     ylab("Reads per million") + 
     ggtitle(label = title, subtitle = subtitle)

w <- ALL_overlaps  %>%
  filter(X17 >= thresholds[i] )  %>% 
  group_by(TEfam) %>%  
  tally() %>% 
  arrange(desc(n)) %>%  head(10) %>% 
  ggplot(aes(x=reorder(TEfam,n), y=n)) + 
  geom_col() +
  theme_light(base_size = 12) + 
  coord_flip() +
  xlab("") +
  ylab("Reads per million") + 
  ggtitle(label = title, subtitle = subtitle)


s <- ALL_overlaps  %>%
  filter(X17 >= thresholds[i] )  %>% 
  filter(method == "Method=structural") %>% 
  group_by(TEfam) %>%  
  tally() %>% 
  arrange( desc(n)) %>%  head(10) %>% 
  ggplot(aes(x=reorder(TEfam,n),y=n)) + 
  geom_col() +
  theme_light(base_size = 12) + 
  coord_flip() +
  xlab("") +
  ylab("Reads per million") + 
  ggtitle(label = title, subtitle = subtitle)


plot_list_class[[i]] <- p
plot_list_fams[[i]] <-  w
plot_list_st[[i]] <-  s
}

# Combine the plots using patchwork
wrap_plots(plot_list_class)
wrap_plots(plot_list_fams)
wrap_plots(plot_list_st)

################################################################################################################ 
################################################################################################################
################################################################################################################
################################################################################################################  

ALL_reads_dante <-   vroom("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/FINAL_TE_annotation/TE_analisis/chimeric_TEs/ALL_reads_dante_filtered.gff3" ,
        col_names = c("sequence_ID", "tool", "type", "start_read", "end_read", "score_read", "strand_read", "phase_read", "atributes_read"), delim = "\t")

ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(prot_name = str_extract(.$atributes_read, "Name=.*")) %>% 
    dplyr::mutate(prot_name = str_remove(prot_name, ";.*$")) %>% 
    dplyr::mutate(prot_name = str_remove(prot_name, "^Name="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Final_Classification = str_extract(.$atributes_read, "Final_Classification=.*")) %>% 
    dplyr::mutate(Final_Classification = str_remove(Final_Classification, ";.*$")) %>% 
    dplyr::mutate(Final_Classification = str_remove(Final_Classification, "^Final_Classification="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Region_Hits_Classifications = str_extract(.$atributes_read, "Region_Hits_Classifications=.*")) %>% 
  dplyr::mutate(Region_Hits_Classifications = str_remove(Region_Hits_Classifications, ";.*$")) %>% 
  dplyr::mutate(Region_Hits_Classifications = str_remove(Region_Hits_Classifications, "^Region_Hits_Classifications="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Best_Hit = str_extract(.$atributes_read, "Best_Hit=.*")) %>% 
  dplyr::mutate(Best_Hit = str_remove(Best_Hit, ";.*$")) %>% 
  dplyr::mutate(Best_Hit = str_remove(Best_Hit, "^Best_Hit="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Best_Hit_DB_Pos = str_extract(.$atributes_read, "Best_Hit_DB_Pos=.*")) %>% 
  dplyr::mutate(Best_Hit_DB_Pos = str_remove(Best_Hit_DB_Pos, ";.*$")) %>% 
  dplyr::mutate(Best_Hit_DB_Pos = str_remove(Best_Hit_DB_Pos, "^Best_Hit_DB_Pos="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(DB_Seq = str_extract(.$atributes_read, "DB_Seq=.*")) %>% 
  dplyr::mutate(DB_Seq = str_remove(DB_Seq, ";.*$")) %>% 
  dplyr::mutate(DB_Seq = str_remove(DB_Seq, "^DB_Seq="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Region_Seq = str_extract(.$atributes_read, "Region_Seq=.*")) %>% 
  dplyr::mutate(Region_Seq = str_remove(Region_Seq, ";.*$")) %>% 
  dplyr::mutate(Region_Seq = str_remove(Region_Seq, "^Region_Seq="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Query_Seq = str_extract(.$atributes_read, "Query_Seq=.*")) %>% 
  dplyr::mutate(Query_Seq = str_remove(Query_Seq, ";.*$")) %>% 
  dplyr::mutate(Query_Seq = str_remove(Query_Seq, "^Query_Seq="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Identity = str_extract(.$atributes_read, "Identity=.*")) %>% 
  dplyr::mutate(Identity = str_remove(Identity, ";.*$")) %>% 
  dplyr::mutate(Identity = str_remove(Identity, "^Identity=")) %>% 
  dplyr::mutate(Identity = as.numeric(Identity))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Similarity = str_extract(.$atributes_read, "Similarity=.*")) %>% 
  dplyr::mutate(Similarity = str_remove(Similarity, ";.*$")) %>% 
  dplyr::mutate(Similarity = str_remove(Similarity, "^Similarity=")) %>% 
  dplyr::mutate(Similarity = as.numeric(Similarity))

ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Relat_Length = str_extract(.$atributes_read, "Relat_Length=.*")) %>% 
  dplyr::mutate(Relat_Length = str_remove(Relat_Length, ";.*$")) %>% 
  dplyr::mutate(Relat_Length = str_remove(Relat_Length, "^Relat_Length="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Relat_Interruptions = str_extract(.$atributes_read, "Relat_Interruptions=.*")) %>% 
  dplyr::mutate(Relat_Interruptions = str_remove(Relat_Interruptions, ";.*$")) %>% 
  dplyr::mutate(Relat_Interruptions = str_remove(Relat_Interruptions, "^Relat_Interruptions="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate(Hit_to_DB_Length = str_extract(.$atributes_read, "Hit_to_DB_Length=.*")) %>% 
  dplyr::mutate(Hit_to_DB_Length = str_remove(Hit_to_DB_Length, ";.*$")) %>% 
  dplyr::mutate(Hit_to_DB_Length = str_remove(Hit_to_DB_Length, "^Hit_to_DB_Length="))
ALL_reads_dante <- ALL_reads_dante  %>%   dplyr::mutate( accession = str_extract(.$atributes_read, "Accession=.*")) %>% 
  dplyr::mutate( accession = str_remove( accession, ";.*$")) %>% 
  dplyr::mutate( accession = str_remove( accession, "_._.*")) %>%
  dplyr::mutate( accession = str_remove( accession, "^Accession="))

path <- "/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/FINAL_TE_annotation/TE_analisis/chimeric_TEs/"
bam_read_counts <-  vroom(file = paste0(path,"bam_reads_count.tsv"), 
                          col_names = c("accession", "total_read_count"), 
                          delim = "\t")
ALL_reads_dante <- dplyr::left_join(ALL_reads_dante,bam_read_counts, by="accession")


##################################
##################################
##################################

merged_dataset <- dplyr::full_join(ALL_reads_dante,ALL_overlaps,by=c("sequence_ID", "accession"))
nrow(ALL_reads_dante)
nrow(ALL_overlaps)
nrow(merged_dataset)

#remove the  nonw WT expressed Col-0 TES

known_TE_WT_Col0_express <- c("SADHU","TSCL","ATSINE2A")
merged_dataset %>%  filter( TEfam %in% known_TE_WT_Col0_express)
merged_dataset_clean <- merged_dataset %>%  filter( !TEfam %in% known_TE_WT_Col0_express)

#################################
#################################
#################################

merged_dataset_clean %>%  
  filter(Identity > 0.9) %>% 
  filter(Similarity > 0.9) %>%   
  group_by(accession, TEfam, prot_name, perc_overlap) %>%  
  tally() %>%  
  ggplot(aes(x=TEfam, y=perc_overlap, size=n, color=prot_name, fill=prot_name)) + 
  scale_color_brewer(palette = "Spectral") + 
  geom_jitter() +  
  coord_flip() + 
  theme_light()

merged_dataset_clean %>%  
  ggplot(aes(x=overlap_bp)) + 
  geom_histogram(bins = 100, binwidth = 10) + 
  geom_vline(xintercept = 299, colour="dodgerblue", linetype = 2, size = 0.5) + 
  theme_light(base_size = 15) + 
  ylab("number of TEs") + 
  xlab("Overlap in bp")

merged_dataset_clean %>%  filter(Identity > 0.9) %>% 
  group_by(accession, feature, prot_name, Identity) %>%  
  tally() %>%  
  ggplot(aes(x=feature, y=n,  fill=prot_name)) + 
  scale_fill_brewer(palette = "Spectral") + 
  geom_col() +
  xlab("") +
  ylab("number of reads") + 
  coord_flip() + 
  theme_light(base_size = 15) + 
  facet_wrap(~accession) +
  theme(
    strip.background = element_rect( fill = "white",  color="white"), 
    strip.text = element_text(colour = "black"))
   

merged_dataset_clean %>%  filter(Identity > 0.9) %>% 
  group_by(accession, feature, TEfam, prot_name) %>%  
  tally() %>%  
  ggplot(aes(x=TEfam, y=n,  fill=prot_name)) + 
  scale_fill_brewer(palette = "Spectral") + 
  geom_col() +
  xlab("") +
  ylab("number of reads") + 
  coord_flip() + 
  theme_light(base_size = 15) + 
  facet_wrap(~accession) +
  theme(
    strip.background = element_rect( fill = "white",  color="white"), 
    strip.text = element_text(colour = "black"))



plot_list <- list()
accession_list <- merged_dataset_clean$accession  %>%  unique()

for(i in 1:length(accession_list)){
  p <- merged_dataset_clean %>%  
    filter(Identity > 0.9) %>%  
    filter(accession == accession_list[i]) %>% 
    group_by(accession, feature, TEfam, prot_name) %>%  
    tally() %>%  
    ggplot(aes(x=TEfam, y=n,  fill=prot_name)) + 
    scale_fill_brewer(palette = "Spectral") + 
    geom_col() +
    xlab("") +
    ylab("number of reads") + 
    coord_flip() + 
    theme_classic(base_size = 15) + 
    facet_wrap(~accession) +
    theme( strip.background = element_rect( fill = "white",  color="white"), 
           strip.text = element_text(colour = "black"))
  
  plot_list[[i]] <-  p
}

# Combine the plots using patchwork
a <- wrap_plots(plot_list[c(1:6)]) +
  plot_layout(guides = "collect")

b <- wrap_plots(plot_list[c(7:12)]) + 
  plot_layout(guides = "collect")

c <- wrap_plots(plot_list[c(13:17)]) + 
  plot_layout(guides = "collect")


merged_dataset_clean %>%  
  filter(Identity > 0.9) %>%  
  group_by(accession, feature, TEfam) %>%  
  tally() %>%  
  group_by(TEfam) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(TEfam,n), y=n)) + 
    geom_col() + 
    theme_light() + 
    coord_flip() + 
    xlab("") + 
    ylab("# Accessions")


##### Visu

# How many TEs  show overlap withh ISo seq but do not express any TE-realted proteins?
# AKA spurious express?

a <- merged_dataset_clean %>%  
  filter(is.na(prot_name)) %>%  
  group_by(TEfam, TEID, feature) %>%  tally() %>%  
  ggplot(aes(x=feature, y=n)) + 
  ylab("Number of TEs") + 
  xlab("") + 
  ggtitle("Isoseq reads that overlap with TEs") + 
  geom_boxplot() +
  theme_light()

# How many TEs show overlap withh ISo seq and express any TE-realted proteins?
b <- merged_dataset_clean %>%  
  filter(!is.na(prot_name)) %>%  
  filter(!is.na(TEID)) %>%  
  group_by(TEfam, TEID, feature) %>%  
  tally() %>% 
  ggplot(aes(x=feature, y=n)) + 
  geom_boxplot() +
  ylab("Number of TEs") + 
  xlab("") + 
  ggtitle("TEs expressing TE-related proteins") + 
  theme_light()

a/b



# How many TEs  show overlap withh ISo seq but do not express any TE-realted proteins?
# AKA spurious express?

merged_dataset_clean %>%  
  filter(is.na(prot_name)) %>%  
  group_by(TEfam, TEID, feature) %>%  tally() %>% 
  ggplot(aes(x=feature, y=n)) +
  ylab("Number of TEs") + 
  xlab("") + 
  ggtitle("Isoseq reads that overlap with TEs") + 
  geom_boxplot() +
  theme_light()

# How many TEs show overlap withh ISo seq and express any TE-realted proteins?
b <- merged_dataset_clean %>%  
  filter(!is.na(prot_name)) %>%  
  filter(!is.na(TEID)) %>%  
  group_by(TEfam, TEID, feature) %>%  
  tally() %>% 
  ggplot(aes(x=feature, y=n)) + 
  geom_boxplot() +
  ylab("Number of TEs") + 
  xlab("") + 
  ggtitle("TEs expressing TE-related proteins") + 
  theme_light()



merged_dataset_clean %>%  
  filter(Identity > 0.9)

