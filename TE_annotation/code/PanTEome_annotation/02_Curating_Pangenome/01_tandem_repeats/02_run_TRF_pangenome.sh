#!/usr/bin/env bash

# We use TRF
echo "Workin version: Tandem Repeats Finder, Version 4.09"

mkdir -p TE_annotation/output/EDTA_curation/01_Tandem_repeats/TRF/
cd TE_annotation/output/EDTA_curation/01_Tandem_repeats/TRF/

# Genome
genome="TE_annotation/input/pangenome.fasta"
# EDTA settings:
align_score=1000 # -e para, dft:1000
max_seed=2000  # maximum period size to report
# MAIN
trf $genome  2 7 7 80 10 $align_score $max_seed -h -l 6 -m -ngs -d > pangenome.fasta.2.7.7.80.10.1000.2000.dat
#  Convert to GFF
python2 TE_annotation/code/trfout2bed.py pangenome.fasta.2.7.7.80.10.1000.2000.dat > pangenome.fasta.2.7.7.80.10.1000.2000.gff
# Convert to bed file
cut -f1,4,5,9 pangenome.fasta.2.7.7.80.10.1000.2000.gff > pangenome.fasta.2.7.7.80.10.1000.2000.bed
