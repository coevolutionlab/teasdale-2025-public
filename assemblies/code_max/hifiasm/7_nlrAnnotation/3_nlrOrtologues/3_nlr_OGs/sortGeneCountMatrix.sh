#!/bin/bash

rm cc-nbs.geneCount.4R
rm cc-nbs-lrr.geneCount.4R
rm nbs-lrr.geneCount.4R
rm rpw8-nbs-lrr.geneCount.4R
rm tir-nbs-lrr.geneCount.4R
rm tir-nbs.geneCount.4R

for line in $(cat CC-NBS.type.IDs); do
	NAME=$(echo $line | awk -F',' '{print $1}')
	grep $NAME nlr.geneCounts.4R > nlr.geneCounts.ordered.4R
	grep $NAME nlr.geneCounts.4R >> cc-nbs.geneCount.4R
done

for line in $(cat CC-NBS-LRR.type.IDs); do
        NAME=$(echo $line | awk -F',' '{print $1}')
        grep $NAME nlr.geneCounts.4R >> nlr.geneCounts.ordered.4R
	grep $NAME nlr.geneCounts.4R >> cc-nbs-lrr.geneCount.4R
done

for line in $(cat NBS-LRR.type.IDs); do
        NAME=$(echo $line | awk -F',' '{print $1}')
        grep $NAME nlr.geneCounts.4R >> nlr.geneCounts.ordered.4R
	grep $NAME nlr.geneCounts.4R >> nbs-lrr.geneCount.4R
done

for line in $(cat RPW8-NBS-LRR.type.IDs); do
        NAME=$(echo $line | awk -F',' '{print $1}')
        grep $NAME nlr.geneCounts.4R >> nlr.geneCounts.ordered.4R
	grep $NAME nlr.geneCounts.4R >> rpw8-nbs-lrr.geneCount.4R
done


for line in $(cat TIR-NBS-LRR.type.IDs); do
        NAME=$(echo $line | awk -F',' '{print $1}')
        grep $NAME nlr.geneCounts.4R >> nlr.geneCounts.ordered.4R
	grep $NAME nlr.geneCounts.4R >> tir-nbs-lrr.geneCount.4R
done

for line in $(cat TIR-NBS.type.IDs); do
        NAME=$(echo $line | awk -F',' '{print $1}')
        grep $NAME nlr.geneCounts.4R >> nlr.geneCounts.ordered.4R
	grep $NAME nlr.geneCounts.4R >> tir-nbs.geneCount.4R
done
