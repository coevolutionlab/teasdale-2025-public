#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../annex/assembly-and-annotation/output/01_assembly/01_pansn-named/at9762.scaffolds-v2.3.fasta

for context in CG CHG CHH
do
    ccsmeth call_freqt \
            --input_path ../../output/at9762/${context}/at9762_${context}.per_readsite.tsv \
            --result_file ../../output/at9762/freqfiles/at9762_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 2 &> ../../output/logfiles/at9762_freq.${context}.log
done
