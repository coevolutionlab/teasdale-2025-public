

# Overview with denovo helitrons

denovo_Helitrons <- pangenome_GFF %>%  filter(X3 == "RC/Helitron") %>%  
  filter(Annotation == "DENOVO") %>%  
  filter(X2 != "EAHelitron") %>%  
  filter(!grepl(".*\\.\\..*", TEfam))


a <- denovo_Helitrons %>%  group_by(Accession, TEfam, TEfam_intacts, RXDB_Hel_domain_fam) %>% tally() %>%  
  #Remove structurally intact Helitrons with no other fam
  filter(!grepl(".*:.*", TEfam)) %>%
  group_by(Accession, RXDB_Hel_domain_fam) %>%  tally() %>%  
  ggplot(aes(x=Accession, y=n, fill=RXDB_Hel_domain_fam)) + 
  geom_col() + 
  scale_fill_manual(values = c("#8e649a","#6095a7")) + 
  theme_light(base_size = 15) + 
  coord_flip()

denovo_Helitrons_summary  <- denovo_Helitrons %>%  filter(!grepl(".*:.*", TEfam)) %>% 
  group_by(Accession, TEfam, TEfam_intacts, RXDB_Hel_domain_fam) %>% 
  tally() %>% 
  filter(!grepl(".*:.*", TEfam)) 

b <- denovo_Helitrons_summary  %>% 
  filter(RXDB_Hel_domain_fam == "No") %>%  
  ggplot(aes(x=TEfam_intacts, y=n, color=RXDB_Hel_domain_fam)) + 
  geom_point() + 
  geom_point(data = denovo_Helitrons_summary  %>% filter(RXDB_Hel_domain_fam == "Yes") , aes(x=TEfam_intacts, y=n, color=RXDB_Hel_domain_fam)) + 
  theme_light(base_size = 15) + 
  scale_color_manual(values = c("#8e649a","#6095a7")) + 
  xlab("Total number of copies") +
  ylab("Intact copies") + 
  coord_flip() + facet_wrap( ~Accession) + 
  theme(strip.background =element_rect(fill="black")) +
  labs(color = "Hel Domain")
  





pangenome_GFF %>%  
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


denovo_Helitrons  %>%  group_by(TEfam ,RXDB_Hel_domain_fam) %>%  
  summarise(mean_identity = mean(as.numeric(identity), na.rm = TRUE), n = n()) %>%  
  mutate(iden_n = mean_identity/n) %>%  ggplot(aes(x=n, y=as.numeric(mean_identity), color=RXDB_Hel_domain_fam)) + 
  geom_point() + 
  theme_light() +
  ylab(" mean family identity") + 
  xlab("number of copies per family")

######################


pangenome_GFF %>%  filter(X3 == "RC/Helitron") %>%   
  filter(X2 != "EAHelitron") %>%  
  filter(!grepl(".*\\.\\..*", TEfam)) %>% 
  group_by(TEfam ,RXDB_Hel_domain_fam) %>%  
  summarise(mean_identity = mean(as.numeric(identity), na.rm = TRUE), n = n()) %>%  
  mutate(iden_n = mean_identity/n) %>%  
  ggplot(aes(x=n, 
             y=as.numeric(mean_identity), 
             color=RXDB_Hel_domain_fam)) + 
  geom_point() + 
  theme_light() +
  ylab(" mean family identity") + 
  xlab("number of copies per family")


#####################

pangenome_GFF %>%  filter(X3 == "RC/Helitron") %>%   
  filter(X2 != "EAHelitron") %>%  
  filter(!grepl(".*\\.\\..*", TEfam)) %>% 
  group_by(TEfam, EAhelitronOverlap) %>%  
  summarise(mean_identity = mean(as.numeric(identity), na.rm = TRUE), n = n()) %>%  
  mutate(iden_n = mean_identity/n) %>%  
  ggplot(aes(x=n, 
             y=as.numeric(mean_identity), 
             color=EAhelitronOverlap)) + 
  geom_point() + 
  scale_color_manual(values = c("#8e649a","#6095a7")) + 
  theme_light() +
  ylab(" mean family identity") + 
  xlab("number of copies per family") + 
  facet_wrap(~ EAhelitronOverlap) +
  theme(strip.background = element_rect(fill="black"))


pangenome_GFF %>%  filter(X3 == "RC/Helitron") %>%   
  filter(X2 != "EAHelitron") %>%  
  filter(!grepl(".*\\.\\..*", TEfam)) %>%  
  group_by(Accession, EAhelitronOverlap) %>%  tally() %>%  
  ggplot(aes(x=Accession, y=n, fill=EAhelitronOverlap)) + 
  geom_col() + 
  theme_light(base_size = 15) + coord_flip() + 
  scale_fill_manual(values = c("#8e649a","#6095a7")) + 
  ylab("# TE copies")
  
