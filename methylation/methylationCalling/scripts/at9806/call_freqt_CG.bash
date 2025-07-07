#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at9806.scaffolds-v2.3.fasta

mkdir -p ../../output/at9806/freqfiles

for context in CG
do
    ccsmeth call_freqt \
            --input_path ../../output/at9806/${context}/at9806_${context}.per_readsite.tsv \
            --result_file ../../output/at9806/freqfiles/at9806_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at9806/at9806_freq.${context}.log
done
