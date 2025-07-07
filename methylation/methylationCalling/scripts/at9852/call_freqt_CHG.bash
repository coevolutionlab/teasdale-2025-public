#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at9852.scaffolds-v2.3.fasta

#mkdir -p ../../output/at9852/freqfiles

for context in CHG
do
    ccsmeth call_freqt \
            --input_path ../../output/at9852/${context}/at9852_${context}.per_readsite.tsv \
            --result_file ../../output/at9852/freqfiles/at9852_${context}_prob08.per_readsite.freq.txt.gz \
            --prob_cf 0.8 \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at9852/at9852_freq_prob08.${context}.log
done
