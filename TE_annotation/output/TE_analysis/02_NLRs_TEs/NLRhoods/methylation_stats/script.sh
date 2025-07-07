#!/usr/bin/env bash

# Input vars:
Gene_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/annotation/latest/ALL_accessions.representatives.gff3"
TE_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome_TEannotation.gff3"
NLR_hoods="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/neighborhoods/latest/final_renamed.bed"
ID_NLR="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/orthogrouping/updated_nlr_list_20231030.txt"
SegmentDups="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/segDuplications/latest/latest_filtered/ALL_biser1.4_editError5_filtered.bedpe"
## Methylation file filtered as minimun number of reads to consider a C to be evaluated for methylation 3. 
Methylation_file="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/methylation/2023-08-28/ALL.mCG.freqBED.filtered_3reads.bed.gz"

################ INTERGENIC #############################
# Retrieve intergenic regions:
gff2bed < ${Gene_anno} > ALL_genes.bed
bedops --difference  ${NLR_hoods}  ALL_genes.bed > intergenic.bed 
# Assign  intergenic regions to the NLR hoods
bedtools intersect  -wo -a intergenic.bed -b  ${NLR_hoods} |
sed '1 i #Chr\tStart\tEnd\tChrom\tStart\tEnd\tNLR_hood\tIntergenic_size' > NLRhoods_intergenic.bed 
# Cleanup
rm ALL_genes.bed intergenic.bed
# Calculate Number of intergenic regions, total size and mean size per NLRhood
bedtools groupby -i NLRhoods_intergenic.bed  -g 4-7 -c 8 -o count,mean,max |
sed '1 i Chr\tStart\tEnd\tNLR_hood\tIntergenic_count\tIntergenic_mean_size\tIntergenic_total_size' > NLRhoods_intergenic_stats.tsv 
# Calculate intergenic methylation
bedtools intersect -wo -a  NLRhoods_intergenic.bed  -b ${Methylation_file} |
bedtools groupby -i - -g 4-7 -c 13 -o count,mean |
sed '1 i Chr\tStart\tEnd\tNLR_hood\tCs_intergenic\tMean_methylation_intergenic' > NLRhoods_intergenic_methylation.tsv
#cleanup 
rm NLRhoods_intergenic.bed

####################### EXONIC ###########################
## NLR ##
# Retrieve NLR exons:
awk '{if($2 == "nlr") print $1}' ${ID_NLR} | grep -f - $Gene_anno |
awk '{if($3 == "exon") print $0}' > NLR_exons.gff3
# Calculate exon number and size per NLRhood
bedtools intersect -wao -a ${NLR_hoods} -b NLR_exons.gff3 |
awk 'BEGIN{OFS="\t"} { print $1,$2,$3,$4,$9-$8}' |
bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean  |
sed '1 i Chr\tStart\tEnd\tNLR_hood\tNLR_exon_number\tNLR_total_size_exon\tNLR_mean_exon_size'  |
awk -F'\t' -v OFS='\t' '$5 == 1 && $6 == 0 {$5=$6=$7=0}1'  >  NLR_exons_stats.tsv 
# Assign NLR exons to the NLR hoods
bedtools intersect -wb -a NLR_exons.gff3  -b  ${NLR_hoods} |
cut -f1,4,5,10-14  > NLR_exonic_hoods.bed
#cleanup
rm NLR_exons.gff3 
# Calculate NLR exonic methylation: 
bedtools intersect -wo -a NLR_exonic_hoods.bed -b ${Methylation_file} |
bedtools  groupby -i - -g 4-7 -c 12 -o count,mean > NLR_exonic_methylation.tsv
sed -i '1 i Chr\tStart\tEnd\tNLR_hood\tCs_NLR_exons\tMean_methylation_NLR_exons' NLR_exonic_methylation.tsv
#cleanup
rm NLR_exonic_hoods.bed

##########
## GENE ##
# Retrieve genes exons:
awk '{if($2 == "nlr") print $1}' ${ID_NLR} | grep -vf - $Gene_anno |
awk '{if($3 == "exon") print $0}' > GENE_exons.gff3
# Calculate exon number and size per NLRhood
bedtools intersect -wao -a ${NLR_hoods} -b GENE_exons.gff3 | 
awk 'BEGIN{OFS="\t"} { print $1,$2,$3,$4,$9-$8}' |
bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean |
sed '1 i\Chr\tStart\tEnd\tNLR_hood\tGenes_exon_number\tGenes_total_size_exon\tGenes_mean_exon_size' |
awk -F'\t' -v OFS='\t' '$5 == 1 && $6 == 0 {$5=$6=$7=0}1' > Gene_exons_stats.tsv
# Assign gene exons to the NLR hoods
bedtools intersect -wb -a GENE_exons.gff3  -b  ${NLR_hoods} |
cut -f1,4,5,10-14  > GENE_exonic_hoods.bed
#cleanup
rm GENE_exons.gff3
# Calculate gene exonic methylation: 
bedtools intersect -wo  -a GENE_exonic_hoods.bed -b ${Methylation_file} |
bedtools groupby -i - -g 4-7 -c 12 -o count,mean > Gene_exonic_methylation.tsv
sed -i '1 i\Chr\tStart\tEnd\tNLR_hood\tCs_Genes_exons\tMean_Methylation_Genes_exons' Gene_exonic_methylation.tsv 
# cleanup
rm GENE_exonic_hoods.bed 
###################### INTRONIC ##########################

### NLR
# Retrieve NLR genes:
awk '{if($2 == "nlr") print $1}' ${ID_NLR} | grep -f - ${Gene_anno} |
awk '{if($3 == "gene") print $0}' > NLR_genes.gff3
# Retrieve NLR exons:
awk '{if($2 == "nlr") print $1}' ${ID_NLR} | grep -f - $Gene_anno |
awk '{if($3 == "exon") print $0}' > NLR_exons.gff3
# Retrieve NLR introns:
gff2bed < NLR_genes.gff3 > NLR_genes.bed
gff2bed < NLR_exons.gff3 > NLR_exons.bed
bedops --difference  NLR_genes.bed NLR_exons.bed  > NLR_introns.bed
# Calculate intron number and size per NLRhood
bedtools intersect -wao  -a ${NLR_hoods} -b NLR_introns.bed |
awk 'BEGIN{OFS="\t"} { print $1,$2,$3,$4,$7-$6}' |
bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean |
awk -F'\t' -v OFS='\t' '$5 == 1 && $6 == 0 {$5=$6=$7=0}1' |
sed '1 i\Chr\tStart\tEnd\tNLR_hood\tNLR_intron_number\tNLR_total_size_intron\tNLR_mean_intron_size' > NLR_introns_stats.tsv
# Assign NLR introns to NLR hoods:
bedtools intersect -wb -a NLR_introns.bed -b  ${NLR_hoods} > NLR_intronic_hoods.bed
# Calculate Methylation in the NLR introns
bedtools intersect -wo -a NLR_intronic_hoods.bed -b ${Methylation_file} |
bedtools groupby -i - -g 4-7 -c 12 -o count,mean > NLR_introns_methylation.tsv
sed -i '1 i\Chr\tStart\tEnd\tNLR_hood\tCs_NLR_introns\tMean_methylation_NLR_introns' NLR_introns_methylation.tsv
#cleanup
rm NLR_genes.gff3 NLR_exons.gff3 NLR_genes.bed NLR_exons.bed NLR_introns.bed NLR_intronic_hoods.bed
##########
## GENE ##
# Retrieve genes:
awk '{if($2 == "nlr") print $1}' ${ID_NLR} | grep -vf - $Gene_anno |
awk '{if($3 == "gene") print $0}' > GENE_genes.gff3
# Retrieve genes exons:
awk '{if($2 == "nlr") print $1}' ${ID_NLR} | grep -vf - $Gene_anno |
awk '{if($3 == "exon") print $0}' > GENE_exons.gff3
# Retrieve genes introns:
gff2bed < GENE_genes.gff3 > GENE_genes.bed
gff2bed < GENE_exons.gff3 > GENE_exons.bed
bedops --difference GENE_genes.bed GENE_exons.bed > GENE_introns.bed
# Assign GENE introns to NLR hoods:
bedtools intersect -wb -a GENE_introns.bed -b  ${NLR_hoods} > GENE_introns_hoods.bed
# cleanup 
rm GENE_introns.bed GENE_genes.gff3 GENE_exons.gff3 GENE_genes.bed GENE_exons.bed 
# Calculate intron number and size per NLRhood
bedtools intersect -wao  -a ${NLR_hoods} -b  GENE_introns_hoods.bed |
awk 'BEGIN{OFS="\t"} { print $1,$2,$3,$4,$7-$6}' |
bedtools groupby -i - -g 1-4 -c 5 -o count,sum,mean |
awk -F'\t' -v OFS='\t' '$5 == 1 && $6 == 0 {$5=$6=$7=0}1' |
sed '1 i\Chr\tStart\tEnd\tNLR_hood\tGENE_intron_number\tGenes_total_size_intron\tGenes_mean_intron_size' > GENE_introns_stats.tsv
# Calculate Methylation in the Gene introns
bedtools intersect -wo -a GENE_introns_hoods.bed -b ${Methylation_file} |
bedtools groupby -i - -g 4-7 -c 12 -o count,mean > GENE_introns_methylation.tsv
sed -i '1 i\Chr\tStart\tEnd\tNLR_hood\tCs_Genes_introns\tMean_methylation_Genes_introns' GENE_introns_methylation.tsv
#cleanup
rm GENE_introns_hoods.bed
