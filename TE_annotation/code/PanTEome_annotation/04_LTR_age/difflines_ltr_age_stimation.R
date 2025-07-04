#!/usr/bin/env Rscrip

# This script calculates LTR ages from the aligments  produced by ltr_age_intacts.sh

#Load the aligments
library(ape)
library(reshape2)
library(stringr)
library(plyr)

# Mutation rate used 
mutation_rate= 9.1*1E-9

genome_list <- c("at6137","at6923","at6929","at7143","at8285","at9104","at9336","at9503","at9578",
                 "at9744","at9762","at9806","at9830","at9847","at9852","at9879","at9883","at9900")

ltr_age_df_list = list()
for (a in 1:length(genome_list)){
  path <- paste0("/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/FINAL_TE_annotation/TE_analisis/ltr_sequences/", 
                 genome_list[a],"_ltrs/")
  filenames=list.files(path, pattern='.aln')
  ages=data.frame(TEname=str_split_fixed(filenames, '\\.', 3)[,1])
  ages$Accession <- genome_list[a]
  ages$k2p=NA
  ages$raw=NA
  ages$tn93=NA
  for (i in 1:length(filenames)){
       ltr=read.FASTA(paste0(path,filenames[i]))
      if( !is.null(ltr) && length(ltr) > 1  ){
        d=ape::dist.dna(ltr, model='K80', variance = TRUE)
        ages$k2p[i]=d
        raw=dist.dna(ltr, model='raw', variance = TRUE)
        ages$raw[i]=raw
        tn93=dist.dna(ltr, model='tn93', variance = TRUE)
        ages$tn93[i]=tn93
        }
  }
  ltr_age_df_list[[a]] <- assign(paste0("ltr_age_",genome_list[a]), ages)
}

ltr_age_all = do.call(rbind, ltr_age_df_list)
ltr_age_all$mya_k2p=ltr_age_all$k2p/(2*mutation_rate)/1E6
ltr_age_all$mya_raw=ltr_age_all$raw/(2*mutation_rate)/1E6
ltr_age_all$mya_tn93=ltr_age_all$tn93/(2*mutation_rate/1E6)

# Plot 
ltr_age_all %>%  
  ggplot(aes(x=mya_k2p)) + 
  geom_density() +
  scale_x_continuous( breaks=scales::breaks_pretty(n = 8), ) + 
  xlab("Mya") + 
  ylab("LTR age estimation") + 
  facet_wrap(~Accession) +
  theme_light() +
  theme(axis.text.x = element_text(angle=45, vjust=0.5, hjust=0.5), 
        panel.spacing = unit(1.2, "lines"),
        strip.background = element_rect(fill="white"),
        strip.text = element_text(color="grey40"))

# Plot numnbero of LTRs
 a <- ltr_age_all %>%  
  group_by(Accession) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(Accession, n), y=n,fill=Accession)) + 
  geom_col() + 
  scale_fill_manual(values = Accession_colors) + 
  xlab("") +
  ylab("# intact LTR TEs") + 
  coord_flip() + 
  theme_light(base_size = 20) +
  theme(legend.position = "none")

 
 # Add same ID as in Pangenome annotation:
 ltr_age_all <-  ltr_age_all %>%  mutate(ID = str_remove(TEname, "ltr_"))


 
 b <- ltr_age_all %>%  
   ggplot(aes(x=mya_k2p, group=Accession, color=Accession)) + 
   geom_density() +
   scale_x_continuous( breaks=scales::breaks_pretty(n = 8), ) + 
   xlab("MYA") +
   ylab("") + 
   ggtitle("LTR age estimation") + 
   theme_light(base_size = 20)  +
   scale_color_manual(values = Accession_colors) +
   theme(legend.position = "none")
 
 TE_intact_LTR <- (a/b)
 
 ggsave(plot =  TE_intact_LTR , path = save_path, filename = "TE_ltr_intact.pdf", dpi = 320)
 
 
# Plot numnbero of LTRs
 a <- ltr_age_all %>%  
  group_by(Accession) %>%  
  tally() %>%  
  ggplot(aes(x=reorder(Accession, n), y=n,fill=Accession)) + 
  geom_col() + 
  scale_fill_manual(values = Accession_colors) + 
  xlab("") +
  ylab("# intact LTR TEs") + 
  coord_flip() + 
  theme_light(base_size = 20) +
  theme(legend.position = "none")

 
 # Add same ID as in Pangenome annotation:
 ltr_age_all <-  ltr_age_all %>%  mutate(ID = str_remove(TEname, "ltr_"))


 
 b <- ltr_age_all %>%  
   ggplot(aes(x=mya_k2p, group=Accession, color=Accession)) + 
   geom_density() +
   scale_x_continuous( breaks=scales::breaks_pretty(n = 8), ) + 
   xlab("MYA") + 
   theme_light(base_size = 25)  +
   scale_color_manual(values = Accession_colors) +
   theme(legend.position = "none")
 
 
 
