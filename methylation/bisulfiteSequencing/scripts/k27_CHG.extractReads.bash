#!/bin/bash
source ~/.bashrc
conda activate ccsmeth



for i in {0..1}
do
    for context in CHG
    do
        ccsmeth \
        extract \
        --input ../input/selfMapped/at9852.hifi_withKinetics_mapped_to_at9852.bam \
        --output ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.${context}_features_k27.txt \
        --gzip \
        --seq_len 27 \
        --motifs ${context} \
        --ref ../input/genome/at9852.scaffolds-v2.3.fasta \
        --holeids_e ../input/selfMapped/CHG_meth${i}_6x.sites.read_ids.txt \
        --mapq 30 \
        --threads 16 \
        --methy_label ${i} \
        --no_supplementary
    done
done
