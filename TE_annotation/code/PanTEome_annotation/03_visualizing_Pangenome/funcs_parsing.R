# This function is used to better parse the TE annotation.

parse_TE_GFF <- function(df) {
  library(stringr)
  library(tidyr)
colnames(df) <- c("Chrom", "Source" , "Feature" , "Start", "End", "Score", "Strand", "Phase", "Attributes")
# TE length
df <- df  %>%
    dplyr::mutate(TE_length = str_extract(.$Attributes, "Length=.*")) %>%
    dplyr::mutate(TE_length = str_remove(TE_length, ";.*$")) %>%
    dplyr::mutate(TE_length = str_remove(TE_length, "^Length=")) %>% 
    dplyr::mutate(TE_length = as.numeric(TE_length))  
# Extract the TE ID 
df <- df  %>%
    dplyr::mutate(ID = str_extract(.$Attributes, "ID=.*")) %>%
    dplyr::mutate(ID = str_remove(ID, ";.*$")) %>%
    dplyr::mutate(ID = str_remove(ID, "^ID="))
# Retrieve method
df <- df  %>%
    dplyr::mutate(method = str_extract(.$Attributes, "Method=.*")) %>%
    dplyr::mutate(method = str_remove(method, ";.*$"))
  # Retrieve Classification
  df <- df  %>%
    dplyr::mutate(classification = str_extract(.$Attributes, "Classification=.*")) %>%
    dplyr::mutate(classification = str_remove(classification, ";.*$")) %>%
    dplyr::mutate(classification = str_remove(classification, "^Classification="))
  
  #Retrieve Sequence ontology
  df <- df  %>%
    dplyr::mutate(so = str_extract(.$Attributes, "Sequence_ontology=.*")) %>%
    dplyr::mutate(so = str_remove(so, ";.*$")) %>%
    dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
  #Retrieve Identity
  df <- df  %>%
    dplyr::mutate(identity = str_extract(.$Attributes, regex("Identity=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(identity = str_remove(identity, ";.*$")) %>%
    dplyr::mutate(identity = str_remove(identity, regex("^Identity=", ignore_case = TRUE))) %>% 
    dplyr::mutate(identity = as.numeric(identity))
  #Retrieve TIR
  df <- df  %>%
    dplyr::mutate(tir = str_extract(.$Attributes,  regex("TIR=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(tir = str_remove(tir, ";.*$")) %>%
    dplyr::mutate(tir = str_remove(tir, regex("^TIR=", ignore_case = TRUE)))
  #Retrieve TSD
  df <- df  %>%
    dplyr::mutate(tsd = str_extract(.$Attributes, regex("TSD=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>%
    dplyr::mutate(tsd = str_remove(tsd, regex("^TSD=", ignore_case = TRUE)))
  #Retrieve TSD score
  df <- df  %>%
    dplyr::mutate(tsd_score = str_extract(.$Attributes, regex("TSD=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>%
    dplyr::mutate(tsd_score = str_remove(tsd_score, regex("^TSD=.*_", ignore_case = TRUE)))
  #Retrieve TEfam
  df <- df  %>%
    dplyr::mutate(TEfam = str_extract(.$Attributes, "Name=.*")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, "^Name=")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, "#.*"))
# Retrieve LTR identity
  df <- df  %>%
    dplyr::mutate(LTR_identity = str_extract(.$Attributes, "ltr_identity=.*")) %>%
    dplyr::mutate(LTR_identity = str_remove(LTR_identity, ";.*$")) %>%
    dplyr::mutate(LTR_identity = str_remove(LTR_identity, "^ltr_identity=")) %>% 
    dplyr::mutate(LTR_identity = as.numeric(LTR_identity)) 
  #Retrieve Accession
  df <- df  %>%
    dplyr::mutate(Accession = .$Chrom) %>%
    dplyr::mutate(Accession = str_remove(Accession, "_.*"))
  #Retrieve  de novos/Tair10
  df <- df  %>%
    dplyr::mutate( Annotation= ifelse(grepl("^TE_|\\.\\.", TEfam),"DENOVO", "TAIR10"))
  # Retrieve TAIR10 homologs
  df <- df  %>%
    dplyr::mutate(TAIR10homolog = str_extract(.$Attributes, "TAIR10homolog=.*$")) %>%
    dplyr::mutate(TAIR10homolog = str_remove(TAIR10homolog, "^TAIR10homolog=")) %>%
    dplyr::mutate(TAIR10homolog = str_remove(TAIR10homolog, ";.*$"))
  
  # Retrieve number of intact helitrons for de novos:
  df <- df  %>%
    dplyr::mutate(TEfam_intacts = str_extract(.$Attributes, "TEfam_intacts=.*;")) %>%
    dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, ";$")) %>%
    dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, "^TEfam_intacts=")) %>%
    dplyr::mutate(TEfam_intacts = as.numeric(TEfam_intacts)) %>%
    mutate(TEfam_intacts = if_else(is.na(TEfam_intacts), 0,TEfam_intacts))
  # Retrieve YES/NO Overlapp with EAhelitron
  df <- df  %>%
    dplyr::mutate(EAhelitronOverlap = str_extract(.$Attributes, "EAhelitronOverlap=.*$")) %>%
    dplyr::mutate(EAhelitronOverlap = str_remove(EAhelitronOverlap, "^EAhelitronOverlap=")) %>%
    dplyr::mutate(EAhelitronOverlap = str_remove(EAhelitronOverlap, ";.*$"))
  
  # Retrieve YES/NO dante Helitron domain in family
  df <- df  %>%
    dplyr::mutate(RXDB_Hel_domain_fam = str_extract(.$Attributes, "RXDB_Hel_domain_fam=.*;")) %>%
    dplyr::mutate(RXDB_Hel_domain_fam = str_remove(RXDB_Hel_domain_fam, ";.*$")) %>%
    dplyr::mutate(RXDB_Hel_domain_fam = str_remove(RXDB_Hel_domain_fam, "^RXDB_Hel_domain_fam=")) %>%
    dplyr::mutate(RXDB_Hel_domain_fam = if_else(is.na(RXDB_Hel_domain_fam), "No",RXDB_Hel_domain_fam))
  
  return(df)
  
}

##########################################################################################
######## This function better  is used to better parse the TE intact  annotation. ########
##########################################################################################

parse_TE_intacts_GFF <- function(df) {
  library(stringr)
  library(tidyr)
  colnames(df) <- c("Chrom", "Source" , "Feature" , "Start", "End", "Score", "Strand", "Phase", "Attributes")
  df <- df  %>%
    dplyr::filter(!grepl("Parent=", Attributes))
  df <- df  %>%
    dplyr::mutate(ID = str_extract(.$Attributes, "ID=.*")) %>%
    dplyr::mutate(ID = str_remove(ID, ";.*$")) %>%
    dplyr::mutate(ID = str_remove(ID, "^ID="))
  df <- df  %>%
    dplyr::mutate(ltr_identity = str_extract(.$Attributes, "ltr_identity=.*")) %>%
    dplyr::mutate(ltr_identity = str_remove(ltr_identity, ";.*$")) %>%
    dplyr::mutate(ltr_identity = str_remove(ltr_identity, "^ltr_identity=")) %>% 
  dplyr::mutate(ltr_identity = as.double(ltr_identity))
  df <- df  %>%
    dplyr::mutate(Classification = str_extract(.$Attributes, "Classification=.*")) %>%
    dplyr::mutate(Classification = str_remove(Classification, ";.*$")) %>%
    dplyr::mutate(Classification = str_remove(Classification, "^Classification="))
# Retrieve Identity
  df <- df  %>%
    dplyr::mutate(Identity = str_extract(.$Attributes, "Identity=.*")) %>%
    dplyr::mutate(Identity = str_remove(Identity, ";.*$")) %>%
    dplyr::mutate(Identity = str_remove(Identity, "^Identity=")) %>% 
    dplyr::mutate(Identity = as.double(Identity))
  # Reitreve Length 
  df <- df  %>%
    dplyr::mutate(Length = str_extract(.$Attributes, "Length=.*")) %>%
    dplyr::mutate(Length = str_remove(Length, ";.*$")) %>%
    dplyr::mutate(Length = str_remove(Length, "^Length=")) %>% 
    dplyr::mutate(length = as.double(Length))
  #Retrieve TEfam
  df <- df  %>%
    dplyr::mutate(TEfam = str_extract(.$Attributes, "Name=.*")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, "^Name=")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, "#.*"))
 #Retrieve Accession
  df <- df  %>%
    dplyr::mutate(Accession = .$Chrom) %>%
    dplyr::mutate(Accession = str_remove(Accession, "_.*"))
  
  return(df)
}



parse_TE_insertions <- function(df) {
  
  library(stringr)
  library(tidyr)
  library(dplyr)  # Make sure to load the dplyr library
  
colnames(df) <- c("Chrom", "Feature", "Attributes", "Feature_gene", "GeneID", "Overlap_bp")
  
 # TE length
df <- df  %>%
    dplyr::mutate(TE_length = str_extract(.$Attributes, "Length=.*")) %>%
    dplyr::mutate(TE_length = str_remove(TE_length, ";.*$")) %>%
    dplyr::mutate(TE_length = str_remove(TE_length, "^Length=")) %>% 
    dplyr::mutate(TE_length = as.numeric(TE_length))  
# Extract the TE ID 
df <- df  %>%
    dplyr::mutate(ID = str_extract(.$Attributes, "ID=.*")) %>%
    dplyr::mutate(ID = str_remove(ID, ";.*$")) %>%
    dplyr::mutate(ID = str_remove(ID, "^ID="))
# Retrieve method
df <- df  %>%
    dplyr::mutate(method = str_extract(.$Attributes, "Method=.*")) %>%
    dplyr::mutate(method = str_remove(method, ";.*$"))
  # Retrieve Classification
  df <- df  %>%
    dplyr::mutate(classification = str_extract(.$Attributes, "Classification=.*")) %>%
    dplyr::mutate(classification = str_remove(classification, ";.*$")) %>%
    dplyr::mutate(classification = str_remove(classification, "^Classification="))
  
  #Retrieve Sequence ontology
  df <- df  %>%
    dplyr::mutate(so = str_extract(.$Attributes, "Sequence_ontology=.*")) %>%
    dplyr::mutate(so = str_remove(so, ";.*$")) %>%
    dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
  #Retrieve Identity
  df <- df  %>%
    dplyr::mutate(identity = str_extract(.$Attributes, regex("Identity=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(identity = str_remove(identity, ";.*$")) %>%
    dplyr::mutate(identity = str_remove(identity, regex("^Identity=", ignore_case = TRUE))) %>% 
    dplyr::mutate(identity = as.numeric(identity))
  #Retrieve TIR
  df <- df  %>%
    dplyr::mutate(tir = str_extract(.$Attributes,  regex("TIR=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(tir = str_remove(tir, ";.*$")) %>%
    dplyr::mutate(tir = str_remove(tir, regex("^TIR=", ignore_case = TRUE)))
  #Retrieve TSD
  df <- df  %>%
    dplyr::mutate(tsd = str_extract(.$Attributes, regex("TSD=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>%
    dplyr::mutate(tsd = str_remove(tsd, regex("^TSD=", ignore_case = TRUE)))
  #Retrieve TSD score
  df <- df  %>%
    dplyr::mutate(tsd_score = str_extract(.$Attributes, regex("TSD=.*", ignore_case = TRUE))) %>%
    dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>%
    dplyr::mutate(tsd_score = str_remove(tsd_score, regex("^TSD=.*_", ignore_case = TRUE)))
  #Retrieve TEfam
  df <- df  %>%
    dplyr::mutate(TEfam = str_extract(.$Attributes, "Name=.*")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, "^Name=")) %>%
    dplyr::mutate(TEfam = str_remove(TEfam, "#.*"))
# Retrieve LTR identity
  df <- df  %>%
    dplyr::mutate(LTR_identity = str_extract(.$Attributes, "ltr_identity=.*")) %>%
    dplyr::mutate(LTR_identity = str_remove(LTR_identity, ";.*$")) %>%
    dplyr::mutate(LTR_identity = str_remove(LTR_identity, "^ltr_identity=")) %>% 
    dplyr::mutate(LTR_identity = as.numeric(LTR_identity)) 
  #Retrieve Accession
  df <- df  %>%
    dplyr::mutate(Accession = .$Chrom) %>%
    dplyr::mutate(Accession = str_remove(Accession, "_.*"))
  #Retrieve  de novos/Tair10
  df <- df  %>%
    dplyr::mutate( Annotation= ifelse(grepl("^TE_|\\.\\.", TEfam),"DENOVO", "TAIR10"))
  # Retrieve TAIR10 homologs
  df <- df  %>%
    dplyr::mutate(TAIR10homolog = str_extract(.$Attributes, "TAIR10homolog=.*$")) %>%
    dplyr::mutate(TAIR10homolog = str_remove(TAIR10homolog, "^TAIR10homolog=")) %>%
    dplyr::mutate(TAIR10homolog = str_remove(TAIR10homolog, ";.*$"))
  
  # Retrieve number of intact helitrons for de novos:
  df <- df  %>%
    dplyr::mutate(TEfam_intacts = str_extract(.$Attributes, "TEfam_intacts=.*;")) %>%
    dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, ";$")) %>%
    dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, "^TEfam_intacts=")) %>%
    dplyr::mutate(TEfam_intacts = as.numeric(TEfam_intacts)) %>%
    mutate(TEfam_intacts = if_else(is.na(TEfam_intacts), 0,TEfam_intacts))
  # Retrieve YES/NO Overlapp with EAhelitron
  df <- df  %>%
    dplyr::mutate(EAhelitronOverlap = str_extract(.$Attributes, "EAhelitronOverlap=.*$")) %>%
    dplyr::mutate(EAhelitronOverlap = str_remove(EAhelitronOverlap, "^EAhelitronOverlap=")) %>%
    dplyr::mutate(EAhelitronOverlap = str_remove(EAhelitronOverlap, ";.*$"))
  
  # Retrieve YES/NO dante Helitron domain in family
  df <- df  %>%
    dplyr::mutate(RXDB_Hel_domain_fam = str_extract(.$Attributes, "RXDB_Hel_domain_fam=.*;")) %>%
    dplyr::mutate(RXDB_Hel_domain_fam = str_remove(RXDB_Hel_domain_fam, ";.*$")) %>%
    dplyr::mutate(RXDB_Hel_domain_fam = str_remove(RXDB_Hel_domain_fam, "^RXDB_Hel_domain_fam=")) %>%
    dplyr::mutate(RXDB_Hel_domain_fam = if_else(is.na(RXDB_Hel_domain_fam), "No",RXDB_Hel_domain_fam))
    
  return(df)
}
