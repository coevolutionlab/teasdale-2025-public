
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



#Merge tandem repeats and rDNA loci:
cat ${satellite_anno} ${rDNA_anno} | bedtools sort -i - -g ${genome_fai}  > repeats.bed 
bedtools merge -i  repeats.bed -d 1000 > repeats_collpased_1000.bed
# cleanup
rm repeats.bed 

# Prepare the genome window files and subtract the satellite regions: 
bedtools makewindows -i winnum -g ${genome_fai} -w 10000 -s 5000 |
bedtools intersect -v -a - -b repeats_collpased_1000.bed > pangenome_chrom_arms_slidinwin_w10k_s5k.bed


# Windowd Densities:

# Intersect with the TE_anno
cat ${TE_anno}  | grep -v "Parent=" | 
bedtools merge -i -  -c 9 -o count > TE_anno_merged.bed
bedtools intersect -wao -a pangenome_chrom_arms_slidinwin_w10k_s5k.bed -b TE_anno_merged.bed |
bedtools groupby -i - -g 1,2,3,4 -c 8,9 -o count,sum |
awk 'BEGIN{OFS=FS="\t"} {if($5 == 1 && $6 == 0) print $1,$2,$3,$4,"All_TEs",0,0,0 ; 
else print $1,$2,$3,$4,"All_TEs",$5,$6,($6/10000)*100}' | 
sed '1 i\#Chrom\tStart\tEnd\tWinnum\tFeature_type\tCount\tSize_bp\tSize_perc_win' > TE_perc_sliding_win_pangenome.tsv
# Intersect with the gene_anno
awk '{if($3 == "gene") print $0}' $gene_anno | 
bedtools merge -i - -c 9 -o count  > gene_anno_merged.bed 
bedtools intersect -wao -a pangenome_chrom_arms_slidinwin_w10k_s5k.bed -b gene_anno_merged.bed |
bedtools groupby -i - -g 1,2,3,4 -c 8,9 -o count,sum |
awk 'BEGIN{OFS=FS="\t"} {if($5 == 1 && $6 == 0) print $1,$2,$3,$4,"Genes",0,0,0 ; 
else print $1,$2,$3,$4,"Genes",$5,$6,($6/10000)*100}' | 
sed '1 i\#Chrom\tStart\tEnd\tWinnum\tFeature_type\tCount\tSize_bp\tSize_perc_win' > gene_perc_sliding_win_pangenome.tsv
# Intersect with the intact TEs:
cat ${TE_anno_intact}  | grep -v "Parent=" | 
bedtools merge -i -  -c 9 -o count > TE_intact_merged.bed
bedtools intersect -wao -a pangenome_chrom_arms_slidinwin_w10k_s5k.bed -b TE_intact_merged.bed |
bedtools groupby -i - -g 1,2,3,4 -c 8,9 -o count,sum |
awk 'BEGIN{OFS=FS="\t"} {if($5 == 1 && $6 == 0) print $1,$2,$3,$4,"Intact_TE",0,0,0 ; 
else print $1,$2,$3,$4,"Intact_TE",$5,$6,($6/10000)*100}' | 
sed '1 i\#Chrom\tStart\tEnd\tWinnum\tFeature_type\tCount\tSize_bp\tSize_perc_win' > TE_intact_perc_sliding_win_pangenome.tsv
# Intersect with the Segmental dups 
awk 'BEGIN{OFS=FS="\t"}{print $1,$2,$3,"ID="NR"\n"$4,$5,$6,"ID="NR}' ${SegmentDups} | 
bedtools sort -i - -g ${genome_fai} |
bedtools merge -i - -c 4 -o count  > segment_dup_merged.bed 
bedtools intersect -wao -a pangenome_chrom_arms_slidinwin_w10k_s5k.bed -b segment_dup_merged.bed  |
bedtools groupby -i - -g 1,2,3,4 -c 8,9 -o count,sum |
awk 'BEGIN{OFS=FS="\t"} {if($5 == 1 && $6 == 0) print $1,$2,$3,$4,"Segdups",0,0,0 ; 
else print $1,$2,$3,$4,"Segdups",$5,$6,($6/10000)*100}' |
sed '1 i\#Chrom\tStart\tEnd\tWinnum\tFeature_type\tCount\tSize_bp\tSize_perc_win' > segdups_perc_sliding_win_pangenome.tsv
# Retrieve the NLRs from the gene annotation:
awk '{if($3 == "gene") print $0}' ${gene_anno}  > gene_annotation.gff3
awk '{if($2 == "nlr") print $1}'  ${ID_NLR} > IDs_NLRs.txt 
grep -f IDs_NLRs.txt gene_annotation.gff3  > NLR_annotation.gff3
# Intersect with the NLR genes:
bedtools merge -i NLR_annotation.gff3 -c 9 -o count  > NLR_anno_merged.bed 
bedtools intersect -wao -a pangenome_chrom_arms_slidinwin_w10k_s5k.bed -b NLR_anno_merged.bed |
bedtools groupby -i - -g 1,2,3,4 -c 8,9 -o count,sum |
awk 'BEGIN{OFS=FS="\t"} {if($5 == 1 && $6 == 0) print $1,$2,$3,$4,"NLRs",0,0,0 ; 
else print $1,$2,$3,$4,"NLRs",$5,$6,($6/10000)*100}' | 
sed '1 i\#Chrom\tStart\tEnd\tWinnum\tFeature_type\tCount\tSize_bp\tSize_perc_win' > NLR_perc_sliding_win_pangenome.tsv
#cleanup
rm TE_anno_merged.bed gene_anno_merged.bed TE_intact_merged.bed
rm segment_dup_merged.bed gene_annotation.gff3 IDs_NLRs.txt 
rm NLR_annotation.gff3 NLR_anno_merged.bed
# Merge 
cat gene_perc_sliding_win_pangenome.tsv NLR_perc_sliding_win_pangenome.tsv \
segdups_perc_sliding_win_pangenome.tsv TE_intact_perc_sliding_win_pangenome.tsv \
TE_perc_sliding_win_pangenome.tsv | bedtools sort -i - -g ${genome_fai}  > Merged_all_counts.tsv 
##########
# Indicate wether a window is a NLR neighborhood or not
bedtools intersect -wao -a Merged_all_counts.tsv  -b ${NLR_hoods} |
awk 'BEGIN{OFS=FS="\t"} {if($9 != ".") print $1,$2,$3,$4,$5,$6,$7,$8,"NLRhood_win",($13/10000)*100 ; 
     else print $1,$2,$3,$4,$5,$6,$7,$8,"genomic_win","." }'  > Pangenome_feature_density.tsv 
# Header 
sed -i '1 i\Chrom\tStart\tEnd\tWinnum\tFeature_type\tCount\tSize_bp\tSize_perc_win\tWin_type\tSize_win_type' Pangenome_feature_density.tsv
# Final cleanup
rm repeats_collpased_1000.bed pangenome_chrom_arms_slidinwin_w10k_s5k.bed gene_perc_sliding_win_pangenome.tsv
rm NLR_perc_sliding_win_pangenome.tsv segdups_perc_sliding_win_pangenome.tsv TE_intact_perc_sliding_win_pangenome.tsv
rm TE_perc_sliding_win_pangenome.tsv Merged_all_counts.tsv
###########
echo "DONE!"
