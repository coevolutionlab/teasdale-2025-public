#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at8285.scaffolds-v2.3.fasta

mkdir -p ../../output/at8285/freqfiles

for context in CG
do
    ccsmeth call_freqt \
            --input_path ../../output/at8285/${context}/at8285_${context}.per_readsite.tsv \
            --result_file ../../output/at8285/freqfiles/at8285_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at8285/at8285_freq.${context}.log
done
