#!/usr/bin/env bash

# Install TE sorter:
# https://github.com/zhangrengang/TEsorter
# conda install -c bioconda tesorter

# Create new dir
mkdir -p TE_annotation/output/EDTA_curation/05_taxonomy/
cd TE_annotation/output/EDTA_curation/05_taxonomy/

# Use New TE libraries product of the curation steps:
pangenome_TElib="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/EDTA_curation/04_orphanTEs/pangenome.TElib.newTEfams.fa"
pangenome_GFF="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/EDTA_curation/04_orphanTEs/Orphans_TEanno_02_cdhit.gff3"
pangenome_intact_GFF="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/EDTA_curation/04_orphanTEs/Orphans_TEintacts_02_cdhit.gff3"
# Fix SADHU SINE classification

sed 's/_SADHU;Classification=Unassigned/_SADHU;Classification=SINE/' $pangenome_GFF > Taxonomic_TEanno_01.gff3
sed 's/_SADHU;Classification=Unassigned/_SADHU;Classification=SINE/' $pangenome_intact_GFF > Taxonomic_TEintact_01.gff3



# Create a list of all TE families and its strucutral/homoloy classification:
grep -v "Parent=" Taxonomic_TEanno_01.gff3 |
cut -f9 | cut -f2,3 -d ';' |
sort | uniq | sed 's/Name=//;s/;Classification=/\t/'  > TE_family_classification.tsv

# Divide families base on this classification and extract the TE models:
mkdir -p {Lines,Sines,LTR,TIR,Unassigned,Helitrons}

# Lines TE models
awk '{if($2 ~ /LINE/ || $2 ~ /RathE/ ) print $1}' TE_family_classification.tsv > Lines/TE_family_classification_Lines.tsv
seqkit grep -w 0 -nrf Lines/TE_family_classification_Lines.tsv  $pangenome_TElib > Lines/pangenome_TElib_Lines.fa
# Sines  TE models
awk '{if($2 ~ /SINE/) print $1}' TE_family_classification.tsv > Sines/TE_family_classification_Sines.tsv
seqkit grep -w 0 -nrf Sines/TE_family_classification_Sines.tsv $pangenome_TElib > Sines/TE_family_classification_Sines.fa
# TIR TE models
awk '{if($2 ~ /DNA/ || $2 ~ /MITE/ || $2 ~ /TIR/) print $1}' TE_family_classification.tsv > TIR/TE_family_classification_TIR.tsv
seqkit grep -w 0 -nrf TIR/TE_family_classification_TIR.tsv $pangenome_TElib > TIR/TE_family_classification_TIR.fa
# LTR TE models
awk '{if($2 ~ /LTR/ ) print $1}' TE_family_classification.tsv > LTR/TE_family_classification_LTR.tsv
seqkit grep -w 0 -nrf LTR/TE_family_classification_LTR.tsv $pangenome_TElib > LTR/TE_family_classification_LTR.fa
# Helitron TE models
awk '{if($2 ~ /Helitron/ ) print $1}' TE_family_classification.tsv > Helitrons/TE_family_classification_Helitron.tsv
seqkit grep -w 0 -nrf Helitrons/TE_family_classification_Helitron.tsv $pangenome_TElib > Helitrons/TE_family_classification_Helitron.fa
# Unassigned
awk '{if($2 ~ /Unassigned/ ) print $1}' TE_family_classification.tsv > Unassigned/TE_family_classification_Unassigned.tsv
seqkit grep -w 0 -nrf Unassigned/TE_family_classification_Unassigned.tsv $pangenome_TElib > Unassigned/TE_family_classification_Unassigned.fa

# Run TEsorter for each division with its corresponding Database if possible (default RexDB):
THREADS=24
# Helitrons

cd Helitrons/
TEsorter TE_family_classification_Helitron.fa  -db rexdb-plant -p $THREADS
cd ../
# Lines
cd Lines/
TEsorter pangenome_TElib_Lines.fa -db rexdb-line -p $THREADS
cd ../
# LTR
cd LTR/
TEsorter TE_family_classification_LTR.fa  -db rexdb-plant -p $THREADS
cd ../
# Sines
cd Sines/
TEsorter TE_family_classification_Sines.fa -db sine -p $THREADS
cd ../
# TIR
cd TIR/
TEsorter TE_family_classification_TIR.fa  -db rexdb-pnas  -p $THREADS
cd ../
# Unassigned
cd Unassigned/
TEsorter TE_family_classification_Unassigned.fa -db rexdb-plant -p $THREADS
cd ../

echo "Done"
