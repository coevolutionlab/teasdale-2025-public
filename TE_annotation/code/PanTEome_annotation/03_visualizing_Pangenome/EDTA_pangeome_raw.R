#!/usr/bin/env Rscript

#install.packages("patchwork")
#install.packages("tidyr")
#install.packages("vroom")

library(ggplot2)
library(patchwork)
library(stringr)
library(vroom)
library(tidyr)

### TE COLORS

TE_colors <- c("DNA_EnSpm" = "#d28bc6",
               "LTR_Copia" = "#6fb445",
               "LTR_Gypsy" = "#9754d1",
               "LTR_unknown" = "#cf46ac",
               "DNA_HAT" = "#b86d54",
               "RC_Helitron" = "#a94a70",
               "LINE_element" = "#4ea98a",
               "DNA_MuDR" = "#725b9a",
               "DNA_Harbinger" = "#657c38",
               "DNA_Mariner" = "#bf9740",
               "DNA"= "#6474d8",
               "Unknown" = "black",
               "non_LTR_retrotransposon"  = "#4f8ec1",
               "LINE_element"  = "#f44336", 
               "SINE_element"  = "#666666")



#File:
pangenome_GFF_original <- vroom("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/evaluation_PANGENOME_EDTA/pangenome.fasta.mod.EDTA.TEanno.gff3", 
                                col_names = FALSE, delim = "\t", skip = 6)

# Add TE length
pangenome_GFF_original <-  pangenome_GFF_original %>% dplyr::mutate(length=X5-X4)
#Retrieve method
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(method = str_extract(.$X9, "Method=.*")) %>% 
  dplyr::mutate(method = str_remove(method, ";.*$"))

#Retrieve Classification
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(classification = str_extract(.$X9, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))
#Retrieve Sequence ontology
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(so = str_extract(.$X9, "Sequence_ontology=.*")) %>% 
  dplyr::mutate(so = str_remove(so, ";.*$")) %>% 
  dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
#Retrieve Identity
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(identity = str_extract(.$X9, "Identity=.*")) %>% 
  dplyr::mutate(identity = str_remove(identity, ";.*$")) %>% 
  dplyr::mutate(identity = str_remove(identity, "^Identity="))
#Retrieve TIR
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(tir = str_extract(.$X9, "TIR=.*")) %>% 
  dplyr::mutate(tir = str_remove(tir, ";.*$")) %>% 
  dplyr::mutate(tir = str_remove(tir, "^TIR="))

#Retrieve TSD
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(tsd = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "^TSD="))
#Retrieve TSD score
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(tsd_score = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, "^TSD=.*_"))

#Retrieve Classification
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(TEfam = str_extract(.$X9, "Name=.*")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, "^Name="))

#Retrieve Accession
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate(Accession = X1) %>% 
  dplyr::mutate(Accession = str_remove(Accession, "#.*"))

#Retrieve  de novos/Tair10
pangenome_GFF_original <- pangenome_GFF_original  %>%  
  dplyr::mutate( Annotation= ifelse(grepl("AT.*", TEfam), "TAIR10", "DENOVO"))

# Retrieve number of intact helitrons for de novos:
pangenome_GFF_original <- pangenome_GFF_original  %>% 
  dplyr::mutate(TEfam_intacts = str_extract(.$X9, "TEfam_intacts=.*;")) %>% 
  dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, ";$")) %>% 
  dplyr::mutate(TEfam_intacts = str_remove(TEfam_intacts, "^TEfam_intacts=")) %>% 
  dplyr::mutate(TEfam_intacts = as.numeric(TEfam_intacts)) %>% 
  mutate(TEfam_intacts = if_else(is.na(TEfam_intacts), 0,TEfam_intacts))


# Retrieve YES/NO Overlapp with EAhelitron

pangenome_GFF_original <- pangenome_GFF_original  %>% 
  dplyr::mutate(EAhelitronOverlap = str_extract(.$X9, "EAhelitronOverlap=.*$")) %>% 
  dplyr::mutate(EAhelitronOverlap = str_remove(EAhelitronOverlap, "^EAhelitronOverlap="))

# Retrieve YES/NO dante Helitron domain in family

pangenome_GFF_original <- pangenome_GFF_original  %>% 
  dplyr::mutate(RXDB_Hel_domain_fam = str_extract(.$X9, "RXDB_Hel_domain_fam=.*;")) %>% 
  dplyr::mutate(RXDB_Hel_domain_fam = str_remove(RXDB_Hel_domain_fam, ";$")) %>% 
  dplyr::mutate(RXDB_Hel_domain_fam = str_remove(RXDB_Hel_domain_fam, "^RXDB_Hel_domain_fam=")) %>%  
  dplyr::mutate(RXDB_Hel_domain_fam = if_else(is.na(RXDB_Hel_domain_fam), "No",RXDB_Hel_domain_fam))


##################

# pangenome_GFF_original_mod %>%
#   dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
#   dplyr::filter(!grepl("ptg.*", X1)) %>%
#   ggplot(aes(x=X4,y=length,color=X11,fill=X11)) + 
#   geom_line() + 
#   facet_grid(X1~X10) +
#   theme_light(base_size = 16) + 
#   theme(legend.title = element_blank(),
#   strip.background =  element_rect(fill = "orange", color = "grey60")) 

pangenome_GFF_original %>%  filter(!grepl("CEN.*", X3))  %>%  
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  filter(!grepl(".*rDNA.*", X3))  %>% 
  filter(!grepl("Satellite", X3))  %>% 
  filter(!grepl("telomere", X3))  %>% 
  group_by(X3,Accession, Annotation) %>%  
  tally() %>%  
  ggplot(aes(x=X3, y=n, fill=Annotation)) + 
  scale_fill_manual(values = c("#AF7AC5", "#85929E")) + 
  geom_col() + 
  xlab("") + 
  ylab("# TE copies") + 
  facet_wrap(~Accession) + 
  coord_flip() + 
  theme_light(base_size = 12) +
  theme(legend.title = element_blank(),
        strip.background =  element_rect(fill = "black")) 


pangenome_GFF_original %>%  filter(!grepl("CEN.*", X3))  %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  filter(!grepl(".*rDNA.*", X3))  %>% 
  filter(!grepl("Satellite", X3))  %>% 
  filter(!grepl("telomere", X3))  %>% 
  group_by(X3,Accession, Annotation) %>%  
  tally() %>%  
  ggplot(aes(x=X3, y=n, fill=Annotation)) + 
  geom_col() + 
  facet_wrap(~Accession) + 
  coord_flip() + 
  theme_light()






a1 <- pangenome_GFF_original_mod %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::group_by(X10) %>%  
  dplyr::tally() %>%  
  ggplot(aes(x=reorder(X10,n),y=n)) + 
  ylab("# denovo TE") + 
  xlab("") + 
  geom_col(fill="royalblue") + 
  theme_light(base_size = 16) + 
  coord_flip()


pangenome_GFF_original_mod %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(X11 != "centromere") %>% 
  dplyr::filter(X11 != "telomere") %>%
  dplyr::filter(X11 != "rDNA") %>%
  dplyr::filter(classification != "pararetrovirus") %>% 
  dplyr::group_by(X10,X11,X3) %>%  dplyr::tally() %>% 
  dplyr::mutate(X3 = str_remove(X3, "_retrotransposon")) %>%
  dplyr::mutate(X3 = str_remove(X3, "_transposon")) %>%
  ggplot(aes(x=X3,y=n, fill=X11)) + 
  geom_col(position = "dodge") +
  xlab("") + 
  ylab("") +
  theme_bw(base_size = 12) +
  facet_wrap(~X10) + 
  coord_flip() +
  theme(legend.title = element_blank(),
        strip.background =  element_rect(fill = "orange", color = "grey60")) 



b2 <- pangenome_GFF_original_mod %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::group_by(X3,X10) %>%  
  dplyr::tally() %>%  
  ggplot(aes(x=reorder(X10,n),y=n)) + 
  ylab("# denovo TE") + 
  xlab("") + 
  geom_col(fill="royalblue") + 
  theme_light(base_size = 12) + 
  coord_flip() + facet_wrap(~X3) +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        strip.background =  element_rect(fill = "black")) 



b2_alternative <- pangenome_GFF_original_mod %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(classification != "pararetrovirus") %>% 
  dplyr::group_by(X10,classification) %>%  
  dplyr::tally() %>%  
  ggplot(aes(x=reorder(classification,n),y=n)) + 
  ylab("# denovo TE") + 
  xlab("") + 
  geom_col(fill="royalblue", color="grey60") + 
  theme_light(base_size = 12) + 
  theme(axis.text.x = element_text(angle=45, hjust = 1), 
        axis.text.y =element_text(size = 8), 
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip() + 
  facet_wrap(~X10)

c1 <-   pangenome_GFF_original_mod %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(!grepl("telomere.*", X3)) %>% 
  dplyr::filter(!grepl(".*CEN", X3)) %>% 
  dplyr::filter(!grepl(".*rDNA", X3)) %>% 
  ggplot(aes(x=X3,y=log2(length), color=X3)) + 
  geom_boxplot() +
  scale_color_manual( values = TE_colors) +
  facet_wrap(~X10) +
  theme_light() +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip()


c2 <-   pangenome_GFF_original_mod %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(grepl("telomere.*|.*CEN|.*rDNA", X3)) %>% 
  ggplot(aes(x=X3,y=log2(length), color=X3)) + 
  geom_boxplot() +
  facet_wrap(~X10) +
  theme_light() +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip()


pangenome_GFF_original %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  ggplot(aes(x=X3,y=log2(length), color=X3)) + 
  geom_boxplot() +
  scale_color_manual( values = TE_colors) +
  facet_wrap(~X10) +
  theme_light() +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip()





pangenome_GFF_original %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(!grepl("telomere.*", X3)) %>% 
  dplyr::filter(!grepl(".*CEN", X3)) %>% 
  dplyr::filter(!grepl(".*rDNA", X3)) %>% 
  dplyr::group_by(X10,X11) %>%  dplyr::tally() %>% 
  ggplot(aes(x=X10,y=n, fill=X11)) + 
  geom_col(color="grey60") +
  ylab("TE number") + 
  xlab("") + 
  theme_light(base_size=18) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.title = element_blank()) 


d1 <- pangenome_GFF_original %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(!grepl("telomere.*", X3)) %>% 
  dplyr::filter(!grepl(".*CEN", X3)) %>% 
  dplyr::filter(!grepl(".*rDNA", X3)) %>% 
  ggplot(aes(x=X10,y=log2(length), fill=X11)) + 
  geom_boxplot() + 
  xlab("") + 
  ylab("TE length in log2") +
  theme_light(base_size=18) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.title = element_blank(),
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  facet_grid(~X11)



a <- pangenome_GFF_original   %>% 
  dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(method!="Method=structural") %>% 
  ggplot(aes(x=Annotation,y=as.double(identity))) +
  geom_boxplot() +
  xlab("") + 
  ylab("%identity") +
  theme_light(base_size = 15)


b <- pangenome_GFF_original_mod  %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  ggplot(aes(y=method)) +
  geom_bar(position = "dodge") +
  xlab("") + 
  ylab("") +
  theme_light(base_size = 15) + facet_wrap(~X11)

a|b



pangenome_GFF_original_mod %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(classification != "pararetrovirus") %>% 
  dplyr::filter(!grepl("telomere.*|.*CEN|.*rDNA", X3)) %>% 
  dplyr::group_by(X10,TEfam,X3) %>%  dplyr::tally() %>% 
  ggplot(aes(x=TEfam, y=n, color=X3)) + geom_point() +
  scale_color_manual(values = TE_colors) + 
  theme_classic(base_size=12) + 
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.line.y = element_blank(),
        legend.title = element_blank(), 
        legend.key = element_blank())



pangenome_GFF_original_mod %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(classification != "pararetrovirus")  %>% 
  dplyr::mutate(log2length = log2(length))  %>%  dplyr::filter(X3 == "RC_Helitron") %>%  
  ggplot(aes(x=log2length)) + geom_histogram() 





######## INTACT ##########

#File:
pangenome_intact_GFF_mod <- vroom("/ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/analisis_pangenome_TEs/pangenome.fasta.mod.EDTA.TEintact_by_accessions.tsv", 
                                  col_names = FALSE)

# Add TE length
pangenome_intact_GFF_mod <-  pangenome_intact_GFF_mod %>% dplyr::mutate(length=X5-X4)
#Retrieve method
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(method = str_extract(.$X9, "Method=.*")) %>% 
  dplyr::mutate(method = str_remove(method, ";.*$"))
#Retrieve Classification
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(classification = str_extract(.$X9, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))
#Retrieve Sequence ontology
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(so = str_extract(.$X9, "Sequence_ontology=.*")) %>% 
  dplyr::mutate(so = str_remove(so, ";.*$")) %>% 
  dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
#Retrieve Identity
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(identity = str_extract(.$X9, "Identity=.*")) %>% 
  dplyr::mutate(identity = str_remove(identity, ";.*$")) %>% 
  dplyr::mutate(identity = str_remove(identity, "^Identity="))
#Retrieve TIR
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(tir = str_extract(.$X9, "TIR=.*")) %>% 
  dplyr::mutate(tir = str_remove(tir, ";.*$")) %>% 
  dplyr::mutate(tir = str_remove(tir, "^TIR="))

#Retrieve TSD
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(tsd = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "^TSD="))
#Retrieve TSD score
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(tsd_score = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, "^TSD=.*_"))

#Retrieve Classification
pangenome_intact_GFF_mod <- pangenome_intact_GFF_mod  %>%  
  dplyr::mutate(TEfam = str_extract(.$X9, "Name=.*")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, "^Name="))


#### TOTAL NUMBER OF PICKED INTACT TEs

pangenome_intact_GFF_mod %>%   
  group_by(X10,X11) %>%  
  tally() %>%  
  ggplot(aes(x=X10,y=n, fill=X11)) + 
  geom_col() + 
  ylab("# Intact TEs") +
  xlab("Accession") + 
  coord_flip() + 
  theme_light(base_size = 16) +
  theme(legend.title = element_blank())

pangenome_intact_GFF_mod %>%   
  group_by(X10,X11) %>%  
  filter(!grepl("at.*" , TEfam)) %>% 
  tally() %>%  
  ggplot(aes(x=X10,y=n, fill=X11)) + 
  geom_col() + 
  ylab("# bona fide Intact TEs") +
  xlab("Accession") + 
  coord_flip() + 
  theme_light(base_size = 16) +
  theme(legend.title = element_blank())

pangenome_intact_GFF_mod %>%   
  group_by(X10,X11,X3) %>%  
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(X3 != "repeat_region") %>% 
  filter(grepl("at.*" , TEfam)) %>% 
  tally() %>%  
  ggplot(aes(x=X10,y=n, fill=X3)) + 
  geom_col() + 
  xlab("Accession") + 
  coord_flip() + 
  facet_wrap(~X11) + 
  theme_light(base_size = 16) +
  theme(legend.title = element_blank()) +
  theme( 
    strip.background =  element_rect(fill = "plum", color = "grey60"))


pangenome_intact_GFF_mod %>%   
  filter(grepl("at.*" , TEfam)) %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  ggplot(aes(x=X3,y=length,  fill=X3)) +
  geom_boxplot() + 
  facet_wrap(~X10) +  
  theme_light(base_size = 16) +
  theme(legend.title = element_blank()) +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "plum", color = "grey60"))


pangenome_intact_GFF_mod %>%   
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  ggplot(aes(x=X3,y=length,  fill=X3)) +
  geom_boxplot() + 
  facet_wrap(~X10) +  
  theme_light(base_size = 16) +
  theme(legend.title = element_blank()) +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "plum", color = "grey60"))


# How many TE familes in the anno have an intact TE representative?

pangenome_intact_GFF_mod$anno <- "intact"
pangenome_GFF_original_mod <- dplyr::left_join(pangenome_GFF_original_mod, pangenome_intact_GFF_mod[,c(20,21)], by ="TEfam") %>%  
  dplyr::mutate(anno = replace_na(anno, "incomplete"))

pangenome_GFF_original_mod %>%     dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(X11 != "centromere") %>% 
  dplyr::filter(X11 != "telomere") %>%
  dplyr::filter(X11 != "rDNA") %>%
  group_by(X3,anno) %>%  tally() %>%  
  ggplot(aes(x=X3, y=n, fill=anno)) + 
  geom_col() + 
  ylab("# TEs") +
  xlab("TE types") + 
  coord_flip()  +
  theme_light(base_size = 12)

pangenome_GFF_original_mod %>%     dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(X11 != "centromere") %>% 
  dplyr::filter(X11 != "telomere") %>%
  dplyr::filter(X11 != "rDNA") %>%
  select(X3,TEfam,anno) %>%  unique() %>%  group_by(X3,anno) %>%  tally() %>% 
  ggplot(aes(x=X3, y=n, fill=anno)) + 
  geom_col() + 
  ylab("# TE families") +
  xlab("TE types") + 
  coord_flip()  +
  theme_light(base_size = 12)





# Overview with denovo helitrons

denovo_Helitrons <- pangenome_GFF_original %>%  filter(X3 == "RC/Helitron") %>%  filter(Annotation == "DeNovo") %>%  filter(X2 != "EAHelitron")


denovo_Helitrons %>%  group_by(Accession, TEfam, TEfam_intacts, RXDB_Hel_domain_fam) %>% tally() %>%  
  #Remove structurally intact Helitrons with no other fam
  filter(!grepl(".*:.*", TEfam)) %>%
  group_by(Accession, RXDB_Hel_domain_fam) %>%  tally() %>%  
  ggplot(aes(x=Accession, y=n, fill=RXDB_Hel_domain_fam)) + 
  geom_col() + 
  theme_light() + 
  coord_flip()

denovo_Helitrons_summary  <- denovo_Helitrons %>%  filter(!grepl(".*:.*", TEfam)) %>% 
  group_by(Accession, TEfam, TEfam_intacts, RXDB_Hel_domain_fam) %>% 
  tally() %>% 
  filter(!grepl(".*:.*", TEfam)) 

denovo_Helitrons_summary  %>% 
  filter(RXDB_Hel_domain_fam == "No") %>%  
  ggplot(aes(x=TEfam_intacts, y=n, color=RXDB_Hel_domain_fam)) + 
  geom_point() + 
  geom_point(data = denovo_Helitrons_summary  %>% filter(RXDB_Hel_domain_fam == "Yes") , aes(x=TEfam_intacts, y=n, color=RXDB_Hel_domain_fam)) + 
  theme_light() + 
  xlab("Total number of copies") +
  ylab("Intact copies") + 
  coord_flip() + facet_wrap( ~Accession) + 
  theme(strip.background =element_rect(fill="black"))





pangenome_GFF_original %>%  
  filter(!grepl("CEN.*", X3))  %>%  
  filter(!grepl(".*rDNA.*", X3))  %>% 
  filter(!grepl("Satellite", X3))  %>% 
  filter(!grepl("telomere", X3))  %>% 
  group_by(X3,Accession, Annotation) %>%  
  tally() %>%  
  ggplot(aes(x=X3, y=n, fill=Annotation)) + 
  geom_col() + 
  facet_wrap(~Accession) + 
  coord_flip() + 
  theme_light()


######################



a1 <- pangenome_GFF_original %>%  dplyr::filter(Annotation == "DeNovo") %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::group_by(Accession) %>%  
  dplyr::tally() %>%  
  ggplot(aes(x=reorder(Accession,n),y=n)) + 
  ylab("# denovo TE") + 
  xlab("") + 
  geom_col(fill="royalblue") + 
  theme_light(base_size = 16) + 
  coord_flip()


pangenome_GFF_original %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(X11 != "centromere") %>% 
  dplyr::filter(X11 != "telomere") %>%
  dplyr::filter(X11 != "rDNA") %>%
  dplyr::filter(classification != "pararetrovirus") %>% 
  dplyr::group_by(X10,X11,X3) %>%  dplyr::tally() %>% 
  dplyr::mutate(X3 = str_remove(X3, "_retrotransposon")) %>%
  dplyr::mutate(X3 = str_remove(X3, "_transposon")) %>%
  ggplot(aes(x=X3,y=n, fill=X11)) + 
  geom_col(position = "dodge") +
  xlab("") + 
  ylab("") +
  theme_bw(base_size = 12) +
  facet_wrap(~X10) + 
  coord_flip() +
  theme(legend.title = element_blank(),
        strip.background =  element_rect(fill = "orange", color = "grey60")) 



b2 <- pangenome_GFF_original %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::group_by(X3,X10) %>%  
  dplyr::tally() %>%  
  ggplot(aes(x=reorder(X10,n),y=n)) + 
  ylab("# denovo TE") + 
  xlab("") + 
  geom_col(fill="royalblue") + 
  theme_light(base_size = 16) + 
  coord_flip() + facet_wrap(~X3) +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "orange", color = "grey60"))



b2_alternative <- pangenome_GFF_original %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(classification != "pararetrovirus") %>% 
  dplyr::group_by(X10,classification) %>%  
  dplyr::tally() %>%  
  ggplot(aes(x=reorder(classification,n),y=n)) + 
  ylab("# denovo TE") + 
  xlab("") + 
  geom_col(fill="royalblue", color="grey60") + 
  theme_light(base_size = 12) + 
  theme(axis.text.x = element_text(angle=45, hjust = 1), 
        axis.text.y =element_text(size = 8), 
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip() + 
  facet_wrap(~X10)

c1 <-   pangenome_GFF_original %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(!grepl("telomere.*", X3)) %>% 
  dplyr::filter(!grepl(".*CEN", X3)) %>% 
  dplyr::filter(!grepl(".*rDNA", X3)) %>% 
  ggplot(aes(x=X3,y=log2(length), color=X3)) + 
  geom_boxplot() +
  scale_color_manual( values = TE_colors) +
  facet_wrap(~X10) +
  theme_light() +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip()


c2 <-   pangenome_GFF_original %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(grepl("telomere.*|.*CEN|.*rDNA", X3)) %>% 
  ggplot(aes(x=X3,y=log2(length), color=X3)) + 
  geom_boxplot() +
  facet_wrap(~X10) +
  theme_light() +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip()


pangenome_GFF_original %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  ggplot(aes(x=X3,y=log2(length), color=X3)) + 
  geom_boxplot() +
  scale_color_manual( values = TE_colors) +
  facet_wrap(~X10) +
  theme_light() +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  coord_flip()





pangenome_GFF_original %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(!grepl("telomere.*", X3)) %>% 
  dplyr::filter(!grepl(".*CEN", X3)) %>% 
  dplyr::filter(!grepl(".*rDNA", X3)) %>% 
  dplyr::group_by(X10,X11) %>%  dplyr::tally() %>% 
  ggplot(aes(x=X10,y=n, fill=X11)) + 
  geom_col(color="grey60") +
  ylab("TE number") + 
  xlab("") + 
  theme_light(base_size=18) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.title = element_blank()) 


d1 <- pangenome_GFF_original %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(!grepl("telomere.*", X3)) %>% 
  dplyr::filter(!grepl(".*CEN", X3)) %>% 
  dplyr::filter(!grepl(".*rDNA", X3)) %>% 
  ggplot(aes(x=X10,y=log2(length), fill=X11)) + 
  geom_boxplot() + 
  xlab("") + 
  ylab("TE length in log2") +
  theme_light(base_size=18) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.title = element_blank(),
        strip.background =  element_rect(fill = "orange", color = "grey60")) + 
  facet_grid(~X11)



a <- pangenome_GFF_original   %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(method!="Method=structural") %>% 
  ggplot(aes(x=X11,y=as.double(identity))) +
  geom_boxplot() +
  xlab("") + 
  ylab("%identity") +
  theme_light(base_size = 15)


b <- pangenome_GFF_original  %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  ggplot(aes(y=method)) +
  geom_bar(position = "dodge") +
  xlab("") + 
  ylab("") +
  theme_light(base_size = 15) + facet_wrap(~X11)

a|b



pangenome_GFF_original %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(classification != "pararetrovirus") %>% 
  dplyr::filter(!grepl("telomere.*|.*CEN|.*rDNA", X3)) %>% 
  dplyr::group_by(X10,TEfam,X3) %>%  dplyr::tally() %>% 
  ggplot(aes(x=TEfam, y=n, color=X3)) + geom_point() +
  scale_color_manual(values = TE_colors) + 
  theme_classic(base_size=12) + 
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.line.y = element_blank(),
        legend.title = element_blank(), 
        legend.key = element_blank())



pangenome_GFF_original %>%  dplyr::filter(X11 == "DENOVO") %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(classification != "pararetrovirus")  %>% 
  dplyr::mutate(log2length = log2(length))  %>%  dplyr::filter(X3 == "RC_Helitron") %>%  
  ggplot(aes(x=log2length)) + geom_histogram() 



######## INTACT ##########

#File:
pangenome_intact_GFF <- vroom("/ebio/abt6_projects7/diffLines_20/annex/TE_annotation/output/evaluation_PANGENOME_EDTA/pangenome.fasta.mod.EDTA.intact.gff3", 
                              col_names = FALSE, delim = "\t")
# Add TE length
pangenome_intact_GFF <-  pangenome_intact_GFF %>% dplyr::mutate(length=X5-X4)
#Retrieve method
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(method = str_extract(.$X9, "Method=.*")) %>% 
  dplyr::mutate(method = str_remove(method, ";.*$"))
#Retrieve Classification
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(classification = str_extract(.$X9, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))
#Retrieve Sequence ontology
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(so = str_extract(.$X9, "Sequence_ontology=.*")) %>% 
  dplyr::mutate(so = str_remove(so, ";.*$")) %>% 
  dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
#Retrieve Identity
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(identity = str_extract(.$X9, "Identity=.*")) %>% 
  dplyr::mutate(identity = str_remove(identity, ";.*$")) %>% 
  dplyr::mutate(identity = str_remove(identity, "^Identity="))
#Retrieve TIR
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(tir = str_extract(.$X9, "TIR=.*")) %>% 
  dplyr::mutate(tir = str_remove(tir, ";.*$")) %>% 
  dplyr::mutate(tir = str_remove(tir, "^TIR="))

#Retrieve TSD
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(tsd = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "^TSD="))
#Retrieve TSD score
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(tsd_score = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, "^TSD=.*_"))

#Retrieve Classification
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(TEfam = str_extract(.$X9, "Name=.*")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, ";.*$")) %>% 
  dplyr::mutate(TEfam = str_remove(TEfam, "^Name="))



#Retrieve Accession
pangenome_intact_GFF <- pangenome_intact_GFF  %>%  
  dplyr::mutate(Accession = X1) %>% 
  dplyr::mutate(Accession = str_remove(Accession, "#.*"))

#Retrieve  de novos/Tair10
pangenome_intact_GFF <- pangenome_intact_GFF %>%  
  dplyr::mutate( Annotation= ifelse(grepl("AT.*", TEfam), "TAIR10", "DeNovo"))

#### TOTAL NUMBER OF PICKED INTACT TEs

pangenome_intact_GFF %>%   
  group_by(X10,X11) %>%  
  tally() %>%  
  ggplot(aes(x=X10,y=n, fill=X11)) + 
  geom_col() + 
  ylab("# Intact TEs") +
  xlab("Accession") + 
  coord_flip() + 
  theme_light(base_size = 16) +
  theme(legend.title = element_blank())

pangenome_intact_GFF %>%   
  group_by(X10,X11) %>%  
  filter(!grepl("at.*" , TEfam)) %>% 
  tally() %>%  
  ggplot(aes(x=X10,y=n, fill=X11)) + 
  geom_col() + 
  ylab("# bona fide Intact TEs") +
  xlab("Accession") + 
  coord_flip() + 
  theme_light(base_size = 16) +
  theme(legend.title = element_blank())

pangenome_intact_GFF %>%   
  group_by(X10,X11,X3) %>%  
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  dplyr::filter(X3 != "repeat_region") %>% 
  filter(grepl("at.*" , TEfam)) %>% 
  tally() %>%  
  ggplot(aes(x=X10,y=n, fill=X3)) + 
  geom_col() + 
  xlab("Accession") + 
  coord_flip() + 
  facet_wrap(~X11) + 
  theme_light(base_size = 16) +
  theme(legend.title = element_blank()) +
  theme( 
    strip.background =  element_rect(fill = "plum", color = "grey60"))


pangenome_intact_GFF %>%   
  filter(grepl("at.*" , TEfam)) %>% 
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  ggplot(aes(x=X3,y=length,  fill=X3)) +
  geom_boxplot() + 
  facet_wrap(~X10) +  
  theme_light(base_size = 16) +
  theme(legend.title = element_blank()) +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "plum", color = "grey60"))


pangenome_intact_GFF %>%   
  dplyr::filter(X3 != "long_terminal_repeat") %>% 
  dplyr::filter(X3 != "target_site_duplication") %>% 
  ggplot(aes(x=X3,y=length,  fill=X3)) +
  geom_boxplot() + 
  facet_wrap(~X10) +  
  theme_light(base_size = 16) +
  theme(legend.title = element_blank()) +
  theme(axis.text.x=element_blank(), 
        axis.ticks.x=element_blank(), 
        legend.title = element_blank(),  
        strip.background =  element_rect(fill = "plum", color = "grey60"))


# How many TE familes in the anno have an intact TE representative?

pangenome_intact_GFF$anno <- "intact"
pangenome_GFF_original <- dplyr::left_join(pangenome_GFF_original, pangenome_intact_GFF[,c(20,21)], by ="TEfam") %>%  
  dplyr::mutate(anno = replace_na(anno, "incomplete"))



# Unknown evaluation 

summary_unknowns <- pangenome_GFF_original %>%  filter(classification =="Unknown") %>%  
  group_by(TEfam) %>%  
  summarise(median = median(length), n = n())


ggplot(data=summary_unknowns, aes(x=n, y=median)) + 
  geom_point() +
  ggrepel::geom_label_repel(data=subset(summary_unknowns, n > 150), aes(x=n,y=median,lebel=TEfam)) + facet_wrap(~Accession)


