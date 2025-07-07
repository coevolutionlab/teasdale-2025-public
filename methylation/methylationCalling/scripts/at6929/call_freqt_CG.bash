#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../../assembly-and-annotation/output/01_assembly/01_pansn-named/at6929.scaffolds-v2.3.fasta

mkdir -p ../../output/at6929/freqfiles

for context in CG
do
    ccsmeth call_freqt \
            --input_path ../../output/at6929/${context}/at6929_${context}.per_readsite.tsv \
            --result_file ../../output/at6929/freqfiles/at6929_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 5 &> ../../output/logfiles_at6929/at6929_freq.${context}.log
done
