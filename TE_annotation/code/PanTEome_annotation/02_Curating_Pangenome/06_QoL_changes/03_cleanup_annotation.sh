#!/usr/bin/env bash


#This script  improves the radibility of the final annotation in several ways.
# First, cleans the third column of the annotation so its easy to parse.
# Secondly, it changes the prefix to the pansm notation.
mkdir -p TE_annotation/output/EDTA_curation/06_QoL/03_cleanup/
cd TE_annotation/output/EDTA_curation/06_QoL/03_cleanup/

### FULL ANNOTATION
pangenome_fasta="TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/new_pangenome.fasta"
pangenome_fai="TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/new_pangenome.fasta.fai"
# GFF files:
pangenome_GFF="TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/all_anno_lifted_full.gff3"
pangenome_intact_GFF="TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/all_anno_lifted_intacts.gff3"
pangenome_satellite_GFF="TE_annotation/output/EDTA_curation/06_QoL/02_liftover_correction/pangenome_sat_repeats_TRF_TRASH_renamed_lifted.gff3"

# Add length of the feature at the end:
awk '{if (/##/) print $0 ; else print $0";Length="$5-$4}' ${pangenome_GFF} > pangenome_QoL_03_TEfull.gff3
awk '{if (/##/) print $0 ; else print $0";Length="$5-$4}' ${pangenome_intact_GFF} > pangenome_QoL_03_TEintacts.gff3


#remove the EAhelitrons:
cat pangenome_QoL_03_TEfull.gff3  | awk '{if($2 !~ /EAHelitron/) print $0}'  > tmp
cat tmp | sed 's/^.*Classification=//;s/;.*$//' > new_column3

# Step 1
sed -i 's/LINE?/LINE/;
s/LINE\/L1/LINE/;
s/LINE\/unknown/LINE/;
s/RathE[1,2,3]_cons/SINE/;
s/DNA\/helitron/RC\/Helitron/;
s/LTR_retrotransposon/\tLTR_unknown/;
s/Gypsy_LTR_retrotransposon\t/LTR_Ty3\t/;
s/L1_LINE_retrotransposon/LINE/;
s/telomere\/telomere/telomere/;
s/DTA/HAT/;
s/DTC/CACTA/;
s/DTH/Harbinger/;
s/DTM/Mutator/;
s/DTT/Mariner/;
s/EnSpm/CACTA/;
s/MuDR/Mutator/;
s/Pogo/Mariner/;
s/Tc1/Mariner/;
s/Copia/Ty1/;
s/Gypsy/Ty3/;
s/TIR\/CACTA_CACTA/DNA\/CACTA/;
s/DNA\/Helitron/RC\/Helitron/;
s/\/CEN[1-6]//;
s/45S_//;
s/5S\///;
s/Chr[3-5]//;
s/rDNA_/rDNA/
' new_column3

paste tmp new_column3 |  awk 'BEGIN{OFS=FS="\t"}{print $1,$2,$10,$4,$5,$6,$7,$8,$9}'  > tmp_clean
rm tmp new_column3

# Remove the rDNA, centromeric , telomeric and satellite annotation from the final TE annotation.
awk '{if($3 !~ /CEN/ && $3 !~/rDNA/ && $3 !~/Satellite/ && $3 !~ /telomere/ ) print $0}' tmp_clean > tmp_clean_TE
# Keep the rDNA as a separate file
awk '{if($3 ~/rDNA/ ) print $0}' tmp_clean > tmp_clean_rDNA

# rDNA annotation:
# Add header   for other repeats (18 lines)
date=$(date +%Y-%m-%d)
printf "##gff-version 3
## date ${date}
## This is a homology-based annotation of rDNA.
## It is based on curated TAIR10 rDNA sequences.
## It is not a comprehensive annotation.
"  > header_rDNA
cat header_rDNA tmp_clean_rDNA > pangenome_rDNA_annotation.gff3
#Cleanup
rm header_rDNA tmp_clean_rDNA

############


### FULL TE ANNOTATION

#Retrieve EA Helitrons
cat pangenome_QoL_03_TEfull.gff3  | awk '{if($2 ~ /EAHelitron/) print $0}'  > EAhelitrons.tmp

# Replace the Name of TAIR10 name for its family name, add the original TE template
#  as a separate Attribute item  call "TAIR10_homolog"

awk '{if($9 ~ /Name=AT[1-5]TE[0-9]*/) print $0,$9}' tmp_clean_TE > tmp_clean_TE_TAIR10
awk '{if($9 !~ /Name=AT[1-5]TE[0-9]*/) print $0}' tmp_clean_TE > tmp_clean_TE_denovo

# ADD TAIR10 Homolog annotation and remplace Name feld
cat tmp_clean_TE_TAIR10 |
awk '{gsub("^.*Name=", "TAIR10_homolog=", $10) ;
gsub(";Classification=.*$","", $10) ;
gsub("Name=AT[1-5]TE[0-9]*_", "Name=", $9)
print $1,$2,$3,$4,$5,$6,$7,$8,$9";"$10}' |
tr ' '  '\t' > tmp_clean_TE_TAIR10_homolog
# Merge everythinf together
cat tmp_clean_TE_TAIR10_homolog tmp_clean_TE_denovo  EAhelitrons.tmp  |
bedtools sort -i - -faidx $pangenome_fai  >  tmp_final

# Add header
date=$(date +%Y-%m-%d)
printf "##gff-version 3
## date ${date}
## Identity: Sequence identity (0-1) between the library sequence and the target region.
## ltr_identity: Sequence identity (0-1) between the left and right LTR regions.
## tsd: target site duplication.
## seqid source sequence_ontology start end score strand phase attribute.
##
## This is the filtered final version.
## This version has Unknown TEs removed,
## Unassigned TE remain as they are present in TAIR10.
## The SADHU family has been assigned as SINE
## This version has been built using all present TAIR10 TEs as template, thus
## it has a corresponding  attribute field: TAIR10_homolog to reflect the
## closest TE in TAIR10.
## The length of the TE has been added as another attribute field: Length.
## This version has several information layers for helitrons:
## Number of intact elements detected by EDTA for the family this helitron belongs to:
## TEfam_intacts=[INTEGER]
## If any element of the family contains a HEL protein domaing from RXDB:
## RXDB_Hel_domain_fam=[Yes/No]
## Overalp with an independent EAhelitron run [Yes/No].
## EAhelitrons (column two) are low confidence helitrons calls and should be treated carefully.
## EAhelitrons were called by EAhelitron tool but not EDTA.
"  > header

cat header tmp_final > pangenome_TEannotation.gff3

#cleanup
rm header tmp_clean_TE tmp_final EAhelitrons.tmp tmp_clean_TE_TAIR10
rm tmp_clean tmp_clean_TE_denovo tmp_clean_TE_TAIR10_homolog


#############

#### For intacts ####

cat pangenome_QoL_03_TEintacts.gff3 |
sed 's/^.*Classification=//;s/;.*$//' > new_column3

# change col 3 
sed -i 's/LINE?/LINE/;
s/LINE\/L1/LINE/;
s/LINE\/unknown/LINE/;
s/RathE[1,2,3]_cons/SINE/;
s/DNA\/helitron/RC\/Helitron/;
s/LTR_retrotransposon/\tLTR_unknown/;
s/Gypsy_LTR_retrotransposon\t/LTR_Ty3\t/;
s/L1_LINE_retrotransposon/LINE/;
s/telomere\/telomere/telomere/;
s/DTA/HAT/;
s/DTC/CACTA/;
s/DTH/Harbinger/;
s/DTM/Mutator/;
s/DTT/Mariner/;
s/EnSpm/CACTA/;
s/MuDR/Mutator/;
s/Pogo/Mariner/;
s/Tc1/Mariner/;
s/Copia/Ty1/;
s/Gypsy/Ty3/;
s/TIR\/CACTA_CACTA/DNA\/CACTA/;
s/DNA\/Helitron/RC\/Helitron/;
' new_column3

paste pangenome_QoL_03_TEintacts.gff3 new_column3 |
awk 'BEGIN{OFS=FS="\t"}{gsub("#.*;Classification", ";Classification", $9) ;
print $1,$2,$10,$4,$5,$6,$7,$8,$9}'  > tmp_clean_intact

awk '{if($9 ~ /Name=AT[1-5]TE[0-9]*/) print $0,$9}' tmp_clean_intact > tmp_clean_intact_TAIR10
awk '{if($9 !~ /Name=AT[1-5]TE[0-9]*/) print $0}' tmp_clean_intact > tmp_clean_intact_denovo

# ADD TAIR10 Homolog annotation and remplace Name feld
cat tmp_clean_intact_TAIR10 |
awk '{gsub("^.*Name=", "TAIR10_homolog=", $10) ;
gsub(";Classification=.*$","", $10) ;
gsub("Name=AT[1-5]TE[0-9]*_", "Name=", $9)
print $1,$2,$3,$4,$5,$6,$7,$8,$9";"$10}' |
tr ' '  '\t'  > tmp_clean_intact_TAIR10_homolog
# cleanup
rm tmp_clean_intact_TAIR10
# Merge everythinf together
cat tmp_clean_intact_TAIR10_homolog  tmp_clean_intact_denovo |
bedtools sort -i - -faidx $pangenome_fai  >  tmp_final_intact

#add header (16 lines)
date=$(date +%Y-%m-%d)
printf "##gff-version 3
## date ${date}
## Identity: Sequence identity (0-1) between the library sequence and the target region.
## ltr_identity: Sequence identity (0-1) between the left and right LTR regions.
## tsd: target site duplication.
## seqid source sequence_ontology start end score strand phase attribute.
##
## This is the filtered final INTACT version.
## This version has Unknown TEs removed,
## Unassigned TE remain as they are present in TAIR10.
## The SADHU family has been assigned as SINE
## This version has been built using all present TAIR10 TEs as template, thus
## it has a corresponding  attribute field: TAIR10_homolog to reflect the
## closest TE in TAIR10.
## This version has several information layers for helitrons:
## Number of intact elements detected by EDTA for the family this helitron belongs to:
## TEfam_intacts=[INTEGER]
## If any element of the family contains a HEL protein domaing from RXDB:
## RXDB_Hel_domain_fam=[Yes/No]
## Overalp with an independent EAhelitron run [Yes/No].
"  > header

cat header tmp_final_intact > pangenome_TEannotation_intact.gff3

#cleanup
rm header tmp_clean_intact  tmp_clean_intact_denovo  tmp_clean_intact_TAIR10
rm tmp_clean_intact_TAIR10_homolog  tmp_final_intact new_column3

##### Satellite Repeat Annotation:

# Create a header for this new file
header=$(printf "##gff-version 3.2.1\n##date $(date +'%Y-%m-%d %H:%M:%S')\n##source TRF and TRASH satellite annotation \n")
printf "%s\n" "$header" > temp_sat_header

cat temp_sat_header ${pangenome_satellite_GFF}  > ../pangenome_sat_repeats_TRF_TRASH.gff3
cd ../

#### Final Steps: Create a folder with all final annotatio

mkdir -p TE_annotation/output/final_TE_annotation/ 
TE_annotation/output/final_TE_annotation/
# Copy new TE models libraries:
cp TE_annotation/output/EDTA_curation/04_orphanTEs/pangenome.TElib.newTEfams.fa TE_annotation/output/final_TE_annotation/
cp TE_annotation/output/EDTA_curation/04_orphanTEs/pangenome.TElib.novel.newTEfams.fa TE_annotation/output/final_TE_annotation/
# Copy Taxonomic evaluation final file:
cp TE_annotation/output/EDTA_curation/05_taxonomy/All_taxonomy_final.tsv TE_annotation/output/final_TE_annotation/

mv pangenome_sat_repeats_TRF_TRASH.gff3 TE_annotation/output/final_TE_annotation/
mv pangenome_rDNA_annotation.gff3 TE_annotation/output/final_TE_annotation/
mv pangenome_TEannotation.gff3 TE_annotation/output/final_TE_annotation/
mv pangenome_TEannotation_intact.gff3 TE_annotation/output/final_TE_annotation/
# Split by accession
cd TE_annotation/output/final_TE_annotation/
mkdir -p TE_annotation/output/final_TE_annotation/split_by_accession/

#accession array
dl20=(
at6137 at6923 at6929 at7143
at8285 at9104 at9336 at9503
at9578 at9744 at9762 at9806
at9830 at9847 at9852 at9879
at9883 at9900
)

for accession in "${dl20[@]}" ; do
     grep "^${accession}" pangenome_TEannotation.gff3 > split_by_accession/${accession}_TE_anno.gff3 ;
     grep "^${accession}" pangenome_TEannotation_intact.gff3 > split_by_accession/${accession}_TE_intact.gff3 ;
     grep "^${accession}" pangenome_sat_repeats_TRF_TRASH.gff3 > split_by_accession/${accession}_sat_annotation.gff3 ;
     grep "^${accession}" pangenome_rDNA_annotation.gff3   > split_by_accession/${accession}_rDNA_annotation.gff3 ;

done

echo "DONE!"
