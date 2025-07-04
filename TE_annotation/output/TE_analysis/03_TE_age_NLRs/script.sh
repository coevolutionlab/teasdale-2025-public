#!/usr/bin/env bash

set -e
set -u
set -o pipefail

# This script calcualtes the distance of each intact LTR to the closest NBhood.
# Files:
genome_fai="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome.fasta.fai"
NLR_hoods="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/neighborhoods/latest/final_renamed.bed"
ID_NLR="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/orthogrouping/updated_nlr_list_20231030.txt"
Gene_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/annotation/latest/ALL_accessions.representatives.gff3"
TE_age="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/03_TE_age_NLRs/pangenome_LTR_age.tsv"
#TEs
TE_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_TEannotation.gff3"
TE_anno_intact="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_TEannotation_intact.gff3"

# Cleanup GENE annotation: 
awk -v OFS='\t' '{if($3 == "gene") {gsub(/;.*/, "", $9); print $0}}' ${Gene_anno} > gene_annotation.gff3 
# Retrieve the NLRs from the gene annotation:
awk '{if($2 == "nlr") print $1}'  ${ID_NLR} > IDs_NLRs.txt 
grep -f IDs_NLRs.txt gene_annotation.gff3 |
bedtools sort -i - -faidx ${genome_fai} | bedtools sort -i - -faidx ${genome_fai} > NLR_annotation.gff3
# Clean the intact  TE annotation:
cat $TE_anno_intact | grep -v "Parent=" | grep -v "^#" | 
cut -f1 -d ';'  | sed 's/ID=//' | bedtools sort -i - -faidx ${genome_fai} > clean_ID_intact_TEanno.gff 
# Calcualte distance to all intact TEs to the closest NLR genes:
bedtools closest -d -a  clean_ID_intact_TEanno.gff  -b  NLR_annotation.gff3 -g ${genome_fai}|
grep -v "\-1" | 
cut -f 9,10,13,14,18,19 > TEID_distance_NLR_genes.tsv
sed -i '1 i\ID\tChrom\tStart\tEnd\tNLR_gene\tdistance_bp' TEID_distance_NLR_genes.tsv 
# Calculate the distance to all intact TEs to the closest non-NLR NBhood
grep -vf IDs_NLRs.txt  gene_annotation.gff3 | bedtools sort -i - -faidx ${genome_fai} > nonNLR_gene_annotation.gff3
# Closest to gene
bedtools closest -d -a  clean_ID_intact_TEanno.gff -b nonNLR_gene_annotation.gff3 -g ${genome_fai} |
grep -v "\-1" | 
cut -f 9,10,13,14,18,19 > TEID_distance_nonNLR_genes.tsv
sed -i '1 i\ID\tChrom\tStart\tEnd\tGene\tdistance_bp' TEID_distance_nonNLR_genes.tsv 
### Now loead this file in the final R script to merge them all.

# Cleanup
rm IDs_NLRs.txt gene_annotation.gff3
rm NLR_annotation.gff3 clean_ID_intact_TEanno.gff
rm nonNLR_gene_annotation.gff3 
