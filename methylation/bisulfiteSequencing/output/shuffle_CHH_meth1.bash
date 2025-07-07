#!/bin/bash
source ~/.bashrc
conda activate ccsmeth


export TMPDIR=../tmp/CHH/
export MEMORY=32.0

echo "tmp is $TMPDIR"
echo "memory is $MEMORY Gb"
echo "Starting shuffle"
for i in 1
do
    zcat ./at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CHH_features.filtered_6x.txt.gz \
        |terashuf \
        |gzip \
        > ./at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CHH_features.filtered_6x.shuffled.txt.gz
done
echo "Shuffle completed"

