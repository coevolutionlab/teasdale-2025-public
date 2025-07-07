#!/usr/env/bin

# This script merges the results of the independent EDTA raw runs into  a common folder where the pangenome is.
# We ran the last steps of the tool from this folder.

# The needed, final, files are:

# # LTR
#pangenome.fasta.mod.LTR.raw.fa
#pangenome.fasta.mod.LTR.intact.fa
#pangenome.fasta.mod.LTR.intact.gff3
#pangenome.fasta.mod.LTRlib.fa
#pangenome.fasta.mod.LTRlib.redundant.fa

# # TIR
#pangenome.fasta.mod.TIR.raw.fa
#pangenome.fasta.mod.TIR.intact.gff3
#pangenome.fasta.mod.TIR.intact.fa
#pangenome.fasta.mod.TIR.intact.bed

# # Helitron
#pangenome.fasta.mod.Helitron.raw.fa
#pangenome.fasta.mod.Helitron.intact.fa
#pangenome.fasta.mod.Helitron.intact.gff3
#pangenome.fasta.mod.Helitron.intact.bed


#Paths
raw_path="TE_annotation/output/EDTA/ALL_genomes_EDTA_raw"
pangenome_raw_path="/ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/genomes/ALL_genomes/pangenome.fasta.mod.EDTA.raw"

# Make the raw folder and the  separate subfolders

cd TE_annotation/output/EDTA/
ln -s
mkdir -p TE_annotation/output/EDTA/pangenome.fasta.mod.EDTA.raw/{LTR,Helitron,TIR}

#Find relevant files:
cd TE_annotation/output/EDTA/ALL_genomes_EDTA_raw/

# LTR

find ${raw_path} -maxdepth 2 -name "*.LTR.raw.fa"  | xargs cat  > ${pangenome_raw_path}/LTR/pangenome.fasta.mod.LTR.raw.fa
find ${raw_path} -maxdepth 2 -name "*.LTR.intact.fa" | xargs cat  > ${pangenome_raw_path}/LTR/pangenome.fasta.mod.LTR.intact.fa
find ${raw_path} -maxdepth 2 -name "*.LTR.intact.gff3" | xargs cat  > ${pangenome_raw_path}/LTR/pangenome.fasta.mod.LTR.intact.gff3
find ${raw_path} -maxdepth 3 -name "*.LTRlib.fa" | xargs cat  > ${pangenome_raw_path}/LTR/pangenome.fasta.mod.LTRlib.fa

cp ${pangenome_raw_path}/LTR/* ${pangenome_raw_path}

# TIR

find ${raw_path} -maxdepth 2 -name "*.TIR.raw.fa"  | xargs cat  > ${pangenome_raw_path}/TIR/pangenome.fasta.mod.TIR.raw.fa
find ${raw_path} -maxdepth 2 -name "*.TIR.intact.fa" | xargs cat  > ${pangenome_raw_path}/TIR/pangenome.fasta.mod.TIR.intact.fa
find ${raw_path} -maxdepth 2 -name "*.TIR.intact.gff3" | xargs cat  > ${pangenome_raw_path}/TIR/pangenome.fasta.mod.TIR.intact.gff3
find ${raw_path} -maxdepth 2 -name "*.TIR.intact.bed" | xargs cat  > ${pangenome_raw_path}/TIR/pangenome.fasta.mod.TIR.intact.bed

cp ${pangenome_raw_path}/TIR/* ${pangenome_raw_path}


# Helitron

find ${raw_path} -maxdepth 2 -name "*.Helitron.raw.fa"  | xargs cat  > ${pangenome_raw_path}/Helitron/pangenome.fasta.mod.Helitron.raw.fa
find ${raw_path} -maxdepth 2 -name "*.Helitron.intact.fa" | xargs cat  > ${pangenome_raw_path}/Helitron/pangenome.fasta.mod.Helitron.intact.fa
find ${raw_path} -maxdepth 2 -name "*.Helitron.intact.gff3" | xargs cat  > ${pangenome_raw_path}/Helitron/pangenome.fasta.mod.Helitron.intact.gff3
find ${raw_path} -maxdepth 2 -name "*.Helitron.intact.bed" | xargs cat  > ${pangenome_raw_path}/Helitron/pangenome.fasta.mod.Helitron.intact.bed

cp ${pangenome_raw_path}/Helitron/* ${pangenome_raw_path}

# Done! Now you can run the rest of the EDTA tool in the script EDTA_pangenome.sh
