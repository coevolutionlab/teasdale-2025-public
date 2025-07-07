#!/bin/bash

source ~/.bashrc

conda activate ccsmeth

methylartist region -i at9852#1#chr1:1-33329945 \
    -d  ../../output/at9852/at9852_CG.txt \
    -p 32 \
    -n CG \
    -r ../../input/genomes/at9852.scaffolds-v2.3.fasta \
    --skip_align_plot 

