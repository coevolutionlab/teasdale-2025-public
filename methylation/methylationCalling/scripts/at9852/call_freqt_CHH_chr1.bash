#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at9852.scaffolds-v2.3.fasta

#mkdir -p ../../output/at9852/freqfiles

for context in CHH
do
    ccsmeth call_freqt \
            --input_path ../../output/at9852/${context}/at9852_${context}_chr1.per_readsite.tsv \
            --result_file ../../output/at9852/at9852_${context}_chr1.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs at9852_1_chr1 \
            --threads 2 &> ../../output/logfiles_at9852/at9852_freq_chr1.${context}.log
done
