#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at9900.scaffolds-v2.3.fasta

mkdir -p ../../output/at9900/freqfiles

for context in CG
do
    ccsmeth call_freqt \
            --input_path ../../output/at9900/${context}/at9900_${context}.per_readsite.tsv \
            --result_file ../../output/at9900/freqfiles/at9900_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at9900/at9900_freq.${context}.log
done
