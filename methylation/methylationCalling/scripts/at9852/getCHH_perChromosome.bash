#!/bin/bash
source ~/.bashrc
conda activate ccsmeth
for i in {2..5}
do 
    samtools view -F2308 -e '![SA]' ../../tmp/at9852.hifi_withKinetics_mapped_to_at9852.bam \
        |cut -f1,3 \
        |grep "at9852_1_chr${i}" \
        |cut -f1| \
        sort -u > ../../input/chromosomes_mapped_readIDs_chr${i}.txt & done
