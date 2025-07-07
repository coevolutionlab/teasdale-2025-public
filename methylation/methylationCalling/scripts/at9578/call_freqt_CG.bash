#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at9578.scaffolds-v2.3.fasta

mkdir -p ../../output/at9578/freqfiles

for context in CG
do
    ccsmeth call_freqt \
            --input_path ../../output/at9578/${context}/at9578_${context}.per_readsite.tsv \
            --result_file ../../output/at9578/freqfiles/at9578_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at9578/at9578_freq.${context}.log
done
