#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at9762.scaffolds-v2.3.fasta

mkdir -p ../../output/at9762/freqfiles

for context in CG
do
    ccsmeth call_freqt \
            --input_path ../../output/at9762/${context}/at9762_${context}.per_readsite.tsv \
            --result_file ../../output/at9762/freqfiles/at9762_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at9762/at9762_freq.${context}.log
done
