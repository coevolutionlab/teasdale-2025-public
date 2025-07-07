#!/bin/bash -l
source ~/.bashrc
conda activate ccsmeth

ccsmeth extract \
	--input ../../tmp/at7143.hifi_withKinetics_mapped_to_at7143.bam \
    --threads 24 \
    --output ../../output/at7143/CHH/at7143_CHH.features.tsv.gz \
    --gzip \
    --motifs CHH \
    --mode align \
	--ref ../../input/annex/assembly-and-annotation/01.assembly/02.pansn_named/at7143.scaffolds-v2.3.fasta \
    --mapq 30 \
    --no_supplementary

