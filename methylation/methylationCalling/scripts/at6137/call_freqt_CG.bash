#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at6137.scaffolds-v2.3.fasta

mkdir -p ../../output/at6137/freqfiles

for context in CG
do
    ccsmeth call_freqt \
            --input_path ../../output/at6137/${context}/at6137_${context}.per_readsite.tsv \
            --result_file ../../output/at6137/freqfiles/at6137_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at6137/at6137_freq.${context}.log
done
