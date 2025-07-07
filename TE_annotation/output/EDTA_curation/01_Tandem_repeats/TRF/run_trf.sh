#!/bin/bash

set -v

# Genome
genome="/tmp/global2/acontreras/difflines_annex_adri/TE_annotation/output/Tandem_repeats_annotation/pangenome.fasta"

# EDTA settings:
align_score=1000 # -e para, dft:1000
max_seed=2000  # maximum period size to report

# MAIN
trf $genome  2 7 7 80 10 $align_score $max_seed -h -l 6 -m -ngs -d > pangenome.fasta.2.7.7.80.10.1000.2000.dat

# You can also change  the dat fiel to a gff file with the python2  script.
python2 trfout2bed.py pangenome.fasta.2.7.7.80.10.1000.2000.dat > pangenome.fasta.2.7.7.80.10.1000.2000.gff
