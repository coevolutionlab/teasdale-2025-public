#!/usr/bin/env bash

mkdir -p TE_annotation/output/EDTA_curation/01_Tandem_repeats/TRASH
cd TE_annotation/output/EDTA_curation/01_Tandem_repeats/TRASH

# Genome
pangenome="TE_annotation/input/pangenome.fasta"
# Tool
TRASH="TE_annotation/code/TRASH/TRASH_run.sh"

# MAIN
bash ${TRASH_run} ${pangenome}


# Digest TRASH OUTPUT
# To fix GFF bug(there is a lack of Attribute column, 9th column, and thus, no newline created).
 awk '{ for(i=1; i<=NF; i++) { printf "%s%s", $i, (i%8==0 ? "\n" : OFS) } }' TRASH_pangenome.fasta.gff |
 tr ' ' '\t'  > TRASH_pangenome.fasta_fix.gff

 # Transform it to bed.
 cat TRASH_pangenome.fasta_fix.gff  |
 awk 'BEGIN{OFS=FS="\t"}{print $1,$4,$5,$3,$6,$7}' > TRASH_pangenome.fasta_fix.bed

# We actually are going to use work with "all.repeats.from.pangenome.fasta.csv"
# file. But we need to convert it from csv to gff format.
tail -n+2 all.repeats.from.pangenome.fasta.csv |
awk 'BEGIN{ OFS="\t" ; FS=","}  {print $8,"TRASH","satellite_DNA",$1,$2,".",$5,
".","ID=Satellite_repeat_"NR";Width="$3";Seq="$4";Class="$6}' |
tr -d '"' > all.repeats.from.pangenome.fasta.gff
