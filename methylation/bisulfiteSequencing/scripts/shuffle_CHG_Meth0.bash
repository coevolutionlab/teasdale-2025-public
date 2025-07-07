#!/bin/bash
export TMPDIR=../tmp/CHG/
export MEMORY=32.0

echo "tmp is $TMPDIR"
echo "memory is $MEMORY Gb"
echo "Starting shuffle"
for i in 0
do
    zcat ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CHG_features.filtered.txt.gz \
        |terashuf \
        |gzip \
        > ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CHG_features.filtered.shuffled.txt.gz
done
echo "Shuffle completed"

