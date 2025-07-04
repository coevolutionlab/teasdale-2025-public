#!/usr/bin/env bash

set -e 
set -u 
set -o pipefail

## Script adapted from Dario Galanti and modified to fit new dataset. 
## Aim: Count TEs overlapping with different genomic features and then correct it 
## for genome space covered by each genomic feature.
## Input 1: TE annotation.
## Input 2: Bed files of genomic features.
# Set working dir:
path="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/"

path="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/TE_analysis/"
# ENV
mkdir -p ${path}02_NLRs_TEs/intersection_TEs_genes/
cd ${path}02_NLRs_TEs/intersection_TEs_genes/

# Files:
genome_fai="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/TE_annotation/TE_annotation/output/final_TE_annotation/pangenome.fasta.fai"
gene_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/annotation/latest/ALL_accessions.representatives.gff3"
NLR_hoods="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/neighborhoods/latest/final_renamed.bed"
ID_NLR="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/orthogrouping/updated_nlr_list_20231030.txt"
#TEs
TE_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_TEannotation.gff3"
TE_anno_intact="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_TEannotation_intact.gff3"
#Segdups
SegmentDups="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/segDuplications/latest/latest_filtered/ALL_biser1.4_editError5_filtered.bedpe"
# Simple repeats 
satellite_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_sat_repeats_TRF_TRASH.gff3"
rDNA_anno="/tmp/global2/acontreras/difflines_annex_adri/adri-annex/final/Repeat_annotation/latest/pangenome_rDNA_annotation.gff3"
#######

## Since gene annotation does not have at6137 remove it from $genome_fai
cat $genome_fai | grep -v at6137 > pangenome.fai

## From the gene annotation, define the different feature files:

# First remove the NLRs from the gene anno:
awk '{if($2 == "nlr" || $2 == "nlr_domain_embedded_non_TE") print $1}' ${ID_NLR} |
grep -vf - $gene_anno | 
awk -v OFS='\t' '{if($3 == "gene" ) {gsub(/;.*/, "", $9); print $9}}' >  gene_list_no_NLRs.tsv

grep -f gene_list_no_NLRs.tsv ${gene_anno} > gene_annotation_no_NLRs.gff
# Then, extract each feature separatedly
mkdir -p anno_feature/
for feature in $(grep -v "^#" gene_annotation_no_NLRs.gff | cut -f3 | sort | uniq ) ; do 
    awk -v OFS='\t' -v feature=${feature} '{if($3 == feature ) {gsub(/;.*/, "", $9); 
    print $1,$4,$5,$9}}' gene_annotation_no_NLRs.gff > anno_feature/anno_${feature}.bed 
done

## From the NLR ID list, create a NLR only annotation: 
awk '{if($2 == "nlr" || $2 == "nlr_domain_embedded_non_TE") print $1}' ${ID_NLR} |
grep -f - $gene_anno  > NLR_anno.gff 
# Then, extract each feature separatedly
mkdir -p NLR_anno_feature/
for feature in $(grep -v "^#" NLR_anno.gff  | cut -f3 | sort | uniq ) ; do 
    awk -v OFS='\t' -v feature=${feature} '{if($3 == feature ) {gsub(/;.*/, "", $9); 
    print $1,$4,$5,$9}}' NLR_anno.gff > NLR_anno_feature/anno_NLR_${feature}.bed 
done

## Create overall intergenic annotation:
cat $TE_anno $gene_anno $satellite_anno $rDNA_anno | cut -f1,4,5 |
sort -k1,1V -k2,2n -k3,3n > ALL_features_anno.bed 
cat $genome_fai  | awk '{print $1"\t"$2}' |
sort -k1,1V -k2,2n > Chrom_sizes.txt 
bedtools complement -i ALL_features_anno.bed -g Chrom_sizes.txt > anno_intergenic.bed
# Create gene intronic annotation:
cut -f1,2,3  anno_feature/anno_exon.bed |
cat - anno_intergenic.bed | sort -k1,1V -k2,2n -k3,3n |
bedtools complement -i - -g Chrom_sizes.txt |
bedtools intersect -a -  -b anno_feature/anno_gene.bed  >  anno_feature/anno_intronic.bed

# Create NLR intronic annotation:
cut -f1,2,3 NLR_anno_feature/anno_NLR_exon.bed |
cat - anno_intergenic.bed | sort -k1,1V -k2,2n -k3,3n |
bedtools complement -i - -g Chrom_sizes.txt |
bedtools intersect -a -  -b NLR_anno_feature/anno_NLR_gene.bed  > NLR_anno_feature/anno_NLR_intronic.bed


################
# Create TE anno in a bed file format and remove at6137 TEs:
# Also remove the denovo TE families:

mkdir -p TE_features/
cat ${TE_anno}  | grep -v "^at6137" | grep -v "Name=TE_000" | 
bedtools merge -i - -d -1 |
sort -k1,1V -k2,2n -k3,3n > TE_features/all_TEs.bed
# Split TEs by Feature
for feature in $(grep -v "^#" $TE_anno |  grep -v "^at6137" | grep -v "Name=TE_000" | cut -f3 | cut -f2 -d '/' | sort | uniq) ; do 
    cat  ${TE_anno} | grep -v "^at6137" | grep -v "Name=TE_000" |
    awk -v OFS='\t' -v feature=${feature} '{if($3 ~ feature ) {gsub(/;.*/, "", $9); 
    print $1,$4,$5,$9}}' |
    bedtools merge -i - -d -1  > TE_features/${feature}.bed ;
done
#Special case for DNA only TEs 
cat  ${TE_anno} | grep -v "^at6137" | grep -v "Name=TE_000" |
awk -v OFS='\t' '{if($3 == "DNA" ) {gsub(/;.*/, "", $9); 
    print $1,$4,$5,$9}}' |
    bedtools merge -i - -d -1  > TE_features/DNA.bed
# Special case for LTR/unknown
mv TE_features/unknown.bed TE_features/LTR_u.bed 
## Cleanup 
rm ALL_features_anno.bed
rm Chrom_sizes.txt
rm anno_feature/anno_mRNA.bed 
rm NLR_anno_feature/anno_NLR_mRNA.bed
### MAIN ####
# MAKE FILE ARRAYS
reg_arr=(global $(ls *anno_feature/anno_*.bed))
#Group_arr=($(ls ${TE_anno}/Feature_*.bed)) #If I want to breakdown the TE anno per family or Feature
Group_arr=( $(ls TE_features/*.bed) )
# INTERSECT ALL CONTEXT AND REGION FILES
fout="./output_intersection.tsv"
echo -e Feature"\t"Group"\t"Num_TEs"\t"Feature_bp"\t"insertions_x_Mb > $fout
# First calculate for whole genome (no intersection)
for reg in ${reg_arr[@]};
do
 if [ $reg == "global" ];
 then
  feature=global
  bp=$(awk '{tot+=$2} END {print tot}' pangenome.fai)
 else
  feature=$(basename $reg .bed | sed 's/anno_//')
  bp=$(awk '{len+=($3-$2)} END {print len}' $reg)
 fi
 for SF in ${Group_arr[@]};
 do
  group=$(basename $SF | sed 's/.bed//')
  if [ $reg == "global" ];
  then
   num=$(bedtools merge -i $SF -d -1 | wc -l)
  else
   num=$(bedtools merge -i $SF -d -1 | bedtools intersect -a stdin -b $reg -u | wc -l)
  fi
  num_xBP=$(echo $num | awk -v bp=$bp '{printf "%.2f", ($0/(bp/1000000))}')
  echo -e $feature"\t"$group"\t"$num"\t"$bp"\t"$num_xBP | tr " " "\t" >> $fout
 done
done
###############
## Add Insertion rate and Insertion density scaled to 1 insertion/MB globally
## NB: We need "global" to be the first line of each family, so we use a trick and temporarily change it to "aglobal"
tmp_fout=TMP_megatemp.txt
echo -e $(head -1 $fout)"\t"Insertion_rate"\t"Insertion_x_MB_global_scaled |
tr " " "\t" > $tmp_fout
tail -n+2 $fout | sed 's/global/aglobal/g' |
sort -k2,2V -k1,1 | sed 's/aglobal/global/g' |
awk 'OFS="\t"{if($1=="global"){TE_n=$3;TEdens=$5;print $0,1,1}else{rate=($3/TE_n);density_rate=($5/TEdens);print $0,rate,density_rate}}' >> $tmp_fout
mv $tmp_fout $fout
