#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../annex/assembly-and-annotation/output/01_assembly/01_pansn-named/at8285.scaffolds-v2.3.fasta

for context in CG CHG CHH
do
    ccsmeth call_freqt \
            --input_path ../../output/at8285/${context}/at8285_${context}.per_readsite.tsv \
            --result_file ../../output/at8285/freqfiles/at8285_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 2 &> ../../output/logfiles/at8285_freq.${context}.log
done
