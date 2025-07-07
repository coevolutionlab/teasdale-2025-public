#!/bin/bash
source ~/.bashrc
conda activate ccsmeth

export TMPDIR=../tmp/CHG/
export MEMORY=32.0

echo "tmp is $TMPDIR"
echo "memory is $MEMORY Gb"
echo "Starting shuffle"
for i in {0..1}
do
    zcat ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CHG_features.filtered_6x.txt.gz \
        |terashuf \
        |gzip \
        > ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CHG_features.filtered_6x.shuffled.txt.gz
done
echo "Shuffle completed"

