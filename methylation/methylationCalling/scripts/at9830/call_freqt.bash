#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../annex/assembly-and-annotation/output/01_assembly/01_pansn-named/at9830.scaffolds-v2.3.fasta

for context in CG CHG CHH
do
    ccsmeth call_freqt \
            --input_path ../../output/at9830/${context}/at9830_${context}.per_readsite.tsv \
            --result_file ../../output/at9830/freqfiles/at9830_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 2 &> ../../output/logfiles/at9830_freq.${context}.log
done
