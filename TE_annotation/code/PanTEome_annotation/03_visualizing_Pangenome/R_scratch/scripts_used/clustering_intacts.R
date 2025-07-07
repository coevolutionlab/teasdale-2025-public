# This file deals with the cd-hit output cluster file: 

clusters_intacts <- vroom("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/FINAL_TE_annotation/cleanup_nested/clusters.fasta.clstr.clean", 
                          col_names = c("Cluster_ID","num_element", "size_element", "Name_element", "perc_identity"))


#Add representative column 
clusters_intacts <- clusters_intacts %>%  mutate( Representative = ifelse( perc_identity == "Representative", "Represenative", "No"))

#Substituve Representative for 100% in identity column and transform to number:
clusters_intacts <- clusters_intacts %>% 
  mutate(perc_identity = ifelse( perc_identity == "Representative", "100%", perc_identity)) %>%  
  mutate(perc_identity= as.numeric(str_remove(perc_identity, "%")))

# Retrieve sizes:
clusters_intacts <- clusters_intacts %>%  mutate(size_element = as.numeric(str_remove(size_element, "aa")))

clusters_intacts %>% 
  dplyr::group_by(Cluster_ID) %>% 
  dplyr::summarise(Value = max(num_element))

### PLOTS

b <- clusters_intacts %>%  filter(size_element > 100) %>% 
  dplyr::group_by(Cluster_ID) %>% dplyr::summarise(Value = max(num_element)+1) %>%  
  ggplot(aes(x=Value)) + 
  geom_histogram() +
  ggtitle("All clusters") + 
  ylab("Cluster Count") +
  xlab("Number of single copy TEs per cluster") + 
  theme_light()


a <- clusters_intacts %>%  filter(size_element > 100) %>% 
  dplyr::group_by(Cluster_ID) %>% dplyr::summarise(Value = max(num_element)+1 ,
                                                   mean_perc_identity=mean(perc_identity), 
                                                   mean_size= mean(size_element),
                                                   min_size = min(size_element)) %>% 
  filter(Value > 1) %>% 
  ggplot(aes(x=Value, y=mean_perc_identity, size=min_size)) + 
  geom_point(alpha = 0.5) +
  xlab("Number of items in Cluster") +
  ylab("Mean % identity of items per cluster") + 
  ggtitle(" For clusters > 1 item") + 
  theme_light()

(b/a)