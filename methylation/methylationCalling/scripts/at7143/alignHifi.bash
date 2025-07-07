#!/bin/bash
source ~/.bashrc
conda activate ccsmeth

reads=../../input/hifiWithKineticsReads-scratch/at7143/at7143.hifi_withKinetics.bam
ref=../../../annex/assembly-and-annotation/output/01_assembly/01_pansn-named/at7143.scaffolds-v2.3.fasta
output=../../tmp/at7143.hifi_withKinetics_mapped_to_at7143.bam
threads=24

nice ccsmeth align_hifi \
    --hifireads ${reads} \
    --ref ${ref} \
    --output ${output} \
    --threads ${threads}
