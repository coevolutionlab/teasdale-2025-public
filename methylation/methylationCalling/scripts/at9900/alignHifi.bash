#!/bin/bash
source ~/.bashrc
conda activate ccsmeth

reads=../../input/hifiWithKineticsReads-scratch/at9900/at9900.hifi_withKinetics.bam
ref=../../input/annex/assembly-and-annotation/01.assembly/02.pansn_named/at9900.scaffolds-v2.3.fasta
output=../../tmp/at9900.hifi_withKinetics_mapped_to_at9900.bam
threads=24

nice ccsmeth align_hifi \
    --hifireads ${reads} \
    --ref ${ref} \
    --output ${output} \
    --threads ${threads}
