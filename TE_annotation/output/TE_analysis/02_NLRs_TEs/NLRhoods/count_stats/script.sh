#!/usr/bin/env bash
# Input vars:
Gene_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/annotation/latest/ALL_accessions.representatives.gff3"
TE_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome_TEannotation.gff3"
NLR_hoods="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/neighborhoods/latest/final_renamed.bed"
ID_NLR="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/orthogrouping/updated_nlr_list_20231030.txt"
SegmentDups="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/segDuplications/latest/latest_filtered/ALL_biser1.4_editError5_filtered.bedpe"
# Bring NLR hoods coordinates
cat ${NLR_hoods} > NLRhoods.bed
# Cleanup GENE annotation: 
awk -v OFS='\t' '{if($3 == "gene") {gsub(/;.*/, "", $9); print $0}}' ${Gene_anno} > gene_annotation.gff3 
# Retrieve the NLRs from the gene annotation:
awk '{if($2 == "nlr") print $1}'  ${ID_NLR} > IDs_NLRs.txt 
grep -f IDs_NLRs.txt gene_annotation.gff3  > NLR_annotation.gff3
# Remove NLRs from gene gff:
grep -vf IDs_NLRs.txt gene_annotation.gff3 > gene_annotation_noNLRs.gff3
## COUNTS AND SIZES 
# Genes:
bedtools intersect -wo -a NLRhoods.bed -b gene_annotation_noNLRs.gff3  | 
cut -f1-4,14 | bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean |
sed '1 i Chr\tStart\tEnd\tNLR_hood\tTotal_genes\tSizes_genes\tMean_size_genes' > NLRhoods_genes.tsv
# NLRs: 
bedtools intersect -wo -a NLRhoods.bed -b NLR_annotation.gff3 |
cut -f1-4,14 | bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean |
sed '1 i Chr\tStart\tEnd\tNLR_hood\tTotal_NLRs\tSizes_NLRs\tMean_size_NLRs' > NLRhoods_NLRs.tsv
# Segmentdups
cat $SegmentDups  | awk 'BEGIN{OFS="\t"} {print $1,$2,$3"\n"$4,$5,$6}' |
bedtools intersect -wo -a NLRhoods.bed -b - |
cut -f1-4,8 | bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean |
sed '1 i Chr\tStart\tEnd\tNLR_hood\tSegmentDups\tSizeSegmentDups\tMean_size_SegmentDups' > NLRhoods_SegmentDups.tsv
# Transposons
grep -v "Parent=" ${TE_anno} |
bedtools intersect -wo -a NLRhoods.bed -b - |
cut -f1-4,14 | bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean |
sed '1 i Chr\tStart\tEnd\tNLR_hood\tTotal_TEs\tSizes_TEs\tMean_size_TEs' > NLRhoods_TEs.tsv
# Remove intermediate files
rm NLRhoods.bed gene_annotation.gff3 IDs_NLRs.txt NLR_annotation.gff3 gene_annotation_noNLRs.gff3
#########
