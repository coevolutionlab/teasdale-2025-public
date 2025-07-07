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

TE_colors <- c("CACTA_TIR_transposon" = "#d28bc6",
               "Copia_LTR_retrotransposon" = "#6fb445",
               "Gypsy_LTR_retrotransposon" = "#9754d1",
               "LTR_retrotransposon" = "#cf46ac",
               "hAT_TIR_transposon" = "#b86d54",
               "helitron" = "#a94a70",
               "LINE_element" = "#4ea98a",
               "Mutator_TIR_transposon" = "#725b9a",
               "PIF_Harbinger_TIR_transposon" = "#657c38",
               "Tc1_Mariner_TIR_transposon" = "#bf9740",
               "TIR_transposon"= "#6474d8",
               "repeat_region" = "black",
               "non_LTR_retrotransposon"  = "#4f8ec1",
               "L1_LINE_retrotransposon"  = "#f44336", 
               "SINE_element"  = "#666666")


#File:
EDTA_18_raw_GFF <- vroom("/ebio/abt6_projects7/diffLines_20/annex/TE_annotation/output/EDTA_TAIR10lib/EDTA_18_raw_GFF.tsv", 
                         col_names = FALSE)
# Add TE length
EDTA_18_raw_GFF <-  EDTA_18_raw_GFF %>% dplyr::mutate(length=X5-X4)

#Retrieve method
EDTA_18_raw_GFF <- EDTA_18_raw_GFF  %>%  
  dplyr::mutate(method = str_extract(.$X9, "Method=.*")) %>% 
  dplyr::mutate(method = str_remove(method, ";.*$"))
#Retrieve Classification
EDTA_18_raw_GFF <- EDTA_18_raw_GFF  %>%  
  dplyr::mutate(classification = str_extract(.$X9, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))
#Retrieve Sequence ontology
EDTA_18_raw_GFF <- EDTA_18_raw_GFF  %>%  
  dplyr::mutate(so = str_extract(.$X9, "Sequence_ontology=.*")) %>% 
  dplyr::mutate(so = str_remove(so, ";.*$")) %>% 
  dplyr::mutate(so = str_remove(so, "^Sequence_ontology="))
#Retrieve Identity
EDTA_18_raw_GFF <- EDTA_18_raw_GFF  %>%  
  dplyr::mutate(identity = str_extract(.$X9, "Identity=.*")) %>% 
  dplyr::mutate(identity = str_remove(identity, ";.*$")) %>% 
  dplyr::mutate(identity = str_remove(identity, "^Identity="))
#Retrieve TIR
EDTA_18_raw_GFF <- EDTA_18_raw_GFF  %>%  
  dplyr::mutate(tir = str_extract(.$X9, "TIR=.*")) %>% 
  dplyr::mutate(tir = str_remove(tir, ";.*$")) %>% 
  dplyr::mutate(tir = str_remove(tir, "^TIR="))

#Retrieve TSD
EDTA_18_raw_GFF <- EDTA_18_raw_GFF  %>%  
  dplyr::mutate(tsd = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "_[0-9].*;.*$")) %>% 
  dplyr::mutate(tsd = str_remove(tsd, "^TSD="))
#Retrieve TSD score
EDTA_18_raw_GFF <- EDTA_18_raw_GFF  %>%  
  dplyr::mutate(tsd_score = str_extract(.$X9, "TSD=.*")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, ";.*$")) %>% 
  dplyr::mutate(tsd_score = str_remove(tsd_score, "^TSD=.*_"))

##################




EDTA_18_raw_GFF %>% dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  ggplot(aes(x=X3,y=length, color=X3)) + 
  geom_boxplot() +
  scale_color_manual( values = TE_colors) +
  facet_wrap(~X10) +
  theme_light() +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank(), 
        legend.title = element_blank()) + 
  coord_flip()


EDTA_18_raw_GFF %>% dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::group_by(X10,X11) %>%  dplyr::tally() %>% 
  ggplot(aes(x=X10,y=n, fill=X11)) + 
  geom_col() +
  ylab("TE number") + 
  xlab("") + 
  theme_light(base_size=18) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.title = element_blank()) 


EDTA_18_raw_GFF %>% dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  ggplot(aes(x=X10,y=length, fill=X11)) + 
  geom_boxplot() +
  xlab("") + 
  theme_light(base_size=18) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.title = element_blank()) 


EDTA_18_raw_GFF %>% dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  ggplot(aes(x=X10,y=length, fill=X11)) + 
  geom_boxplot() +
  xlab("") + 
  ylab("TE length") +
  theme_light(base_size=18) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.title = element_blank())  + 
  facet_grid(~X11)



a <- EDTA_18_raw_GFF %>% dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::filter(method!="Method=structural") %>% 
  ggplot(aes(x=X11,y=as.double(identity))) +
  geom_boxplot() +
  xlab("") + 
  ylab("% identity") +
  theme_light(base_size = 15)


b <- EDTA_18_raw_GFF %>% dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  ggplot(aes(y=method)) +
  geom_bar(position = "dodge") +
  xlab("") + 
  ylab("") +
  theme_light(base_size = 18) + facet_wrap(~X11)



 EDTA_18_raw_GFF %>% dplyr::filter(!grepl(".*Parent.*", X9)) %>% 
  dplyr::group_by(X10,X11,X3) %>%  dplyr::tally() %>% 
  dplyr::mutate(X3 = str_remove(X3, "_retrotransposon")) %>%
  dplyr::mutate(X3 = str_remove(X3, "_transposon")) %>%
  ggplot(aes(x=X3,y=n, fill=X11)) + 
  geom_col(position = "dodge") +
  xlab("") + 
  ylab("") +
  theme_bw(base_size = 16) +
  facet_wrap(~X10) + 
  coord_flip() +
  theme(legend.title = element_blank()) 
