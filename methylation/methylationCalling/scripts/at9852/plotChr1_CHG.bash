#!/bin/bash

source ~/.bashrc

conda activate ccsmeth

methylartist region -i at9852#1#chr1:1-33329945 \
    -d  at9852_CHG.txt \
    -p 48 \
    -n CHG \
    -r ../../input/genomes/at9852.scaffolds-v2.3.fasta \
    --skip_align_plot 

