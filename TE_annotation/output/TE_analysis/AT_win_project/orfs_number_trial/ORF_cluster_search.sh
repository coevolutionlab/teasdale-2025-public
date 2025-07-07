#!/usr/bin/env bash

# This script masks annotated features of the pangenome: TEs, Genes, rDNA and Sat repeats and  retireves intergenic regions.
# Then it searches for clusters of ORFs as  hallmarks of possible viruses in the genome. 

# Genome files (CHANGE THIS):
genome="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome.fasta"
genome_fai="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome.fasta.fai"

# Annotation files (CHANGE THIS):
panGeneAnno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/annotation/latest]$ realpath ALL_ACCESSIONS_hodgepodgemerged.gff3"
panTErDNA="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_rDNA_annotation.gff3"
panSat="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_sat_repeats_TRF_TRASH.gff3"
panTEanno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_TEannotation.gff3"



## Create overall intergenic annotation:

cat $panTEanno $panGeneAnno $panSat $panTErDNA | cut -f1,4,5 |
sort -k1,1V -k2,2n -k3,3n > ALL_features_anno.bed ;
cat $genome_fai  | awk '{print $1"\t"$2}' |
sort -k1,1V -k2,2n > Chrom_sizes.txt ;
bedtools complement -i ALL_features_anno.bed -g Chrom_sizes.txt |
awk '{print $0"\tintergenic_interval_"NR}' > anno_intergenic.bed

## Translate intergenic to fasta and retrieve stats

bedtools getfasta -fi $genome -bed  anno_intergenic.bed > intergeninc_region.fa
seqkit stats  intergeninc_region.fa > intergenic.stats.txt 
# Cleanup
rm intergeninc_region.fa


## Filtrer by minimun size of 1000bp

# Create intervals for those windows and give them a cute name.
awk '{if($3-$2 >= 1000) print $0}' anno_intergenic.bed |
bedtools makewindows -b anno_intergenic.bed  -w 5000 -s 1000 -i srcwinnum > Intergenic_intervals_named.bed
# Retrieve fasta sequence
awk '{if($3-$2 >= 1000) print $0}' Intergenic_intervals_named.bed |
bedtools getfasta -fi $genome -bed  - -name  > intergenic_region_filtered.fa
sed -i 's/::.*//' intergenic_region_filtered.fa
# Retrieve stats
seqkit stats intergenic_region_filtered.fa > intergenic_region_filtered_stats.txt

# Get the number of ORFS per intergenic interval with a minimun size of 50:
getorf -sequence intergenic_region_filtered.fa -minsize 50  --outseq ORFS_Intergenic_Region.orfs
# Cleanup filtered fasta sequence
rm intergenic_region_filtered.fa


## Retrieve number of ORFS per window:

cat  ORFS_Intergenic_Region.orfs | grep ">" | sed 's/>//' |
cut -f1-4 -d '_' | uniq -c  | awk '{print $2"\t"$1}' | sort -nrk2 > Number_orfs_per_intergenic_interval_window.tsv

