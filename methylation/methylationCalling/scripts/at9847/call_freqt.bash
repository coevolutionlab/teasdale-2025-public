#!/bin/bash
source ~/.bashrc
conda activate ccsmeth_v2

ref=../../../annex/assembly-and-annotation/output/01_assembly/01_pansn-named/at9847.scaffolds-v2.3.fasta

for context in CG CHG CHH
do
    ccsmeth call_freqt \
            --input_path ../../output/at9847/${context}/at9847_${context}.per_readsite.tsv \
            --result_file ../../output/at9847/freqfiles/at9847_${context}.per_readsite.freq.txt.gz \
            --gzip --sort \
            --motifs ${context}\
            --bed \
            --contigs ${ref} \
            --threads 2 &> ../../output/logfiles/at9847_freq.${context}.log
done
