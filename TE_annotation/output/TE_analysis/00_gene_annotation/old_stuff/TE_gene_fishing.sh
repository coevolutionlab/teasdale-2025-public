#!/usr/bin/env bash

# This script searches for gene models that are completely within annotated TEs.
# These genes are thouhg to be TE coding genes and thus not part of the host protein codin geen fraction.


# FILES:

pangenome_gene_models="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/00_gene_annotation/pangenome_hodgepodgemerged.representatives.gff3"
TE_annotation="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome_TEannotation.gff3"

# Clean gene models

cat $pangenome_gene_models | awk 'BEGIN{OFS=FS="\t"} {if($3 ~ /gene/) print $0}' > only.genes.tmp

# Do the intersection:

bedtools intersect -wb -F 1 -a ${TE_annotation} -b only.genes.tmp  > intersect_F1.tsv

# Extract the gene gff
cat intersect_F1.tsv |
cut -f10-18 | sort -k1,1V -k4,4n -k5,5n | uniq > genes_within_TEs.gff


# Extract the IDs
cat intersect_F1.tsv |
cut -f 18 |
cut -f1 -d ';' | sort | uniq > genes_within_TEs.ID.txt

# Cleanup

rm intersect_F1.tsv


# Now the same but with the family merged annotation

TE_annotation2="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/merging_by_fam/final_TE_annotation_merged_fam.bed"

# Do the intersection:

bedtools intersect -wb -F 1 -a ${TE_annotation2} -b only.genes.tmp  > intersect_F1_merge.tsv

# Extract the gene gff
cat intersect_F1_merge.tsv |
cut -f5-13 | sort -k1,1V -k4,4n -k5,5n | uniq > genes_within_TEs_merge.gff

# Extract the IDs
cat intersect_F1_merge.tsv |
cut -f 13 |
cut -f1 -d ';' | sort | uniq > genes_within_TEs_merge.ID.txt
# Cleanup
rm intersect_F1_merge.tsv
rm only.genes.tmp
