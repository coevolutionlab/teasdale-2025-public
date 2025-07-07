#PAV POLYMORPHIMS


file="/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/evaluation_PANGENOME_EDTA/Helitrons/Helitron_PAVs/pangenome.fasta.mod.EDTA.TEanno_final_PAV_eval.gff3"

ANNO_PAVS <- vroom(file, col_names = FALSE)


ANNO_PAVS <- ANNO_PAVS %>%  dplyr::mutate(PAV = str_extract(.$X9, ";PAV=.*")) %>% 
  dplyr::mutate(PAV = str_remove(PAV, ";PAV=")) %>% 
  
# Add TE length
  ANNO_PAVS <-  ANNO_PAVS %>% dplyr::mutate(length=X5-X4)
#Retrieve method
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(method = str_extract(.$X9, "Method=.*")) %>% 
  dplyr::mutate(method = str_remove(method, ";.*$"))

#Retrieve Classification
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(classification = str_extract(.$X9, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))
#Retrieve Sequence ontology
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(so = str_extract(.$X9, "Sequence_ontology=.*")) %>% 
  dplyr::mutate(so = str_remove(so, ";.*$")) %>% 
  dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
#Retrieve Identity
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(identity = str_extract(.$X9, "Identity=.*")) %>% 
  dplyr::mutate(identity = str_remove(identity, ";.*$")) %>% 
  dplyr::mutate(identity = str_remove(identity, "^Identity="))
#Retrieve TIR
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(tir = str_extract(.$X9, "TIR=.*")) %>% 
  dplyr::mutate(tir = str_remove(tir, ";.*$")) %>% 
  dplyr::mutate(tir = str_remove(tir, "^TIR="))

#Retrieve TSD
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(tsd = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "^TSD="))
#Retrieve TSD score
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(tsd_score = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, "^TSD=.*_"))

#Retrieve Classification
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(TEfam = str_extract(.$X9, "Name=.*")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, "^Name="))

#Retrieve Accession
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate(Accession = X1) %>% 
  dplyr::mutate(Accession = str_remove(Accession, "#.*"))

#Retrieve  de novos/Tair10
ANNO_PAVS <- ANNO_PAVS  %>%  
  dplyr::mutate( Annotation= ifelse(grepl("AT.*", TEfam), "TAIR10", "DENOVO"))

# Retrieve number of intact helitrons for de novos:
ANNO_PAVS <- ANNO_PAVS  %>% 
  dplyr::mutate(TEfam_intacts = str_extract(.$X9, "TEfam_intacts=.*;")) %>% 
  dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, ";$")) %>% 
  dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, "^TEfam_intacts=")) %>% 
  dplyr::mutate(TEfam_intacts = as.numeric(TEfam_intacts)) %>% 
  mutate(TEfam_intacts = if_else(is.na(TEfam_intacts), 0,TEfam_intacts))




ANNO_PAVS %>%  group_by(PAV) %>%  tally()  %>% 
  dplyr::mutate(PAV = tidyr::replace_na(PAV, "OTHER_TE")) %>% 
  ggplot(aes(x=PAV ,y=n)) + 
  geom_col() + 
  theme_light(base_size = 20) + 
  ylab("count") + 
  xlab("")

ANNO_PAVS %>%  group_by(PAV,Annotation) %>%  tally()  %>% 
  dplyr::mutate(PAV = tidyr::replace_na(PAV, "OTHER_TE")) %>% 
  ggplot(aes(x=PAV ,y=n)) + 
  geom_col() + 
  theme_light(base_size = 20) + 
  ylab("count") + 
  xlab("") +
  facet_wrap(~Annotation) +
  theme(strip.background =  element_rect(fill = "white")) +  
  theme(strip.text = element_text(colour = 'grey40', face="bold"))



ANNO_PAVS %>%  group_by(PAV,Annotation,Accession) %>%  tally()  %>% 
  dplyr::mutate(PAV = tidyr::replace_na(PAV, "OTHER_TE")) %>% 
  ggplot(aes(x=Accession ,y=n), fill=PAV) + 
  geom_col(aes(fill=PAV)) + 
  theme_light() + 
  ylab("count") + 
  xlab("") + facet_wrap(~Annotation) + 
  coord_flip() + 
  theme(strip.background =  element_rect(fill = "white")) +  
  theme(strip.text = element_text(colour = 'grey40'))


ANNO_PAVS %>%  group_by(PAV,Annotation,Accession) %>%  tally()  %>% 
  dplyr::mutate(PAV = tidyr::replace_na(PAV, "OTHER_TE")) %>% 
  ggplot(aes(x=Accession ,y=n), fill=PAV) + 
  geom_col(aes(fill=PAV)) + 
  theme_light() + 
  ylab("count") + 
  xlab("") + facet_wrap(~Annotation) + 
  coord_flip() + 
  theme(strip.background =  element_rect(fill = "white")) +  
  theme(strip.text = element_text(colour = 'grey40'))


