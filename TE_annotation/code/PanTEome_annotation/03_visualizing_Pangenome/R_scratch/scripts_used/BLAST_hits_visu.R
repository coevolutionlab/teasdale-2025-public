# This scirpot deals with the output fdo BLAST FAMvsFAM  hits

#Libraries

library(vroom)
library(dplyr)
library(ggplot2)

### TE COLORS

TE_colors <- c("DNA/CACTA" = "#d28bc6",
               "LTR/Ty1" = "#6fb445",
               "LTR/Ty3" = "#9754d1",
               "LTR/unknown" = "#cf46ac",
               "DNA/HAT" = "#b86d54",
               "RC/Helitron" = "#a94a70",
               "LINE" = "#4ea98a",
               "DNA/Mutator" = "#725b9a",
               "DNA/Harbinger" = "#657c38",
               "DNA/Mariner" = "#bf9740",
               "DNA"= "#6474d8",
               "SINE"  = "#666666")

# Load  ANNOTATION GFF and formate it 

Annotation <-  vroom("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/TE_analisis/BLAST_TE_FAMS/pangenome_TEannotation.gff3", 
                  col_names = FALSE, skip = 8)
# Add TE length
Annotation <-  Annotation %>% dplyr::mutate(length=X5-X4)
#Retrieve Classification
Annotation <- Annotation  %>%  
  dplyr::mutate(classification = str_extract(.$X9, "Classification=.*")) %>% 
  dplyr::mutate(classification = str_remove(classification, ";.*$")) %>% 
  dplyr::mutate(classification = str_remove(classification, "^Classification=")) %>% 
  dplyr::mutate(classification = str_replace(classification, "Unassigned", "Unknown"))

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
#Retrieve  de novos/Tair10
Annotation <- Annotation  %>%  
  dplyr::mutate( Annotation= ifelse(grepl("AT.*", TEfam), "TAIR10", "DENOVO"))
#Consolidate families 
Annotation <- Annotation %>%  dplyr::mutate(TEfam = str_remove(TEfam, "AT[:digit:]+TE[:digit:]+_")) 





#Load datasheet:

RESULTS <-  vroom("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/TE_analisis/toy_results.txt", 
                  col_names = c( "TEfam", "query_id","subject_id","identity_per","alignment_length","mismatches","gap_opens",
                                 "q.start","q.end","s.start","s.end","evalue","bitscore","querycov_subject_per"))

# READY? GOGO

# WE have a majority of solo TEs i ntrhe anno:
Annotation %>%  group_by(TEfam) %>%  tally()  %>% ggplot(aes(x=n)) + geom_histogram() 

#Extract anno information and join!
Anno_info <-  Annotation %>%  group_by(TEfam,X3,Annotation) %>%  tally() %>%
  filter(!grepl(".*rDNA.*", X3)) %>% 
  filter(!grepl(".*CEN.*", X3)) %>% 
  filter(!grepl("telomere", X3)) %>% 
  filter(!grepl("Satellite", X3)) %>% 
  filter(!grepl("Unknown", X3)) %>% 
  filter(!grepl("RathE.*", X3)) %>% 
  filter(!grepl("Unassigned", X3))

colnames(Anno_info) <-  c("TEfam", "superfamily", "Annotation", "inds")

# JOIN BOTH
# Make sure to include only  TEfams with more than 1 ind 

RESULTS <-  left_join( RESULTS, Anno_info, by="TEfam") %>%  filter( inds > 1 )



RESULTS %>%  group_by(TEfam, inds, query_id) %>%  tally() %>% 
            mutate(per_hits = n/inds ) %>%  ggplot(aes(x=per_hits)) + geom_histogram()

RESULTS_summarized <-   RESULTS %>% group_by(TEfam, superfamily,inds) %>%
                          summarise_at(vars(alignment_length, identity_per, querycov_subject_per, gap_opens, mismatches, evalue), 
                          funs(mean(., na.rm=TRUE)))




RESULTS_summarized  %>%  ggplot(aes(x=identity_per, y=querycov_subject_per, color=superfamily)) + 
  geom_point() +
  scale_color_manual(values = TE_colors) + 
  theme_light() +
  facet_wrap(~superfamily)

