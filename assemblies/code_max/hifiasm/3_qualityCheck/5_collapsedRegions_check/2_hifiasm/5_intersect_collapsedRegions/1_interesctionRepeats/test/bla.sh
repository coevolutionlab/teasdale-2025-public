#!/bin/bash

for i in $(ls at*.snp.bed); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $NAME.repeatAnnotation.gff | awk '$1 ~/^Chr/ && $2 == "RepeatMasker"' > $NAME.repeats.bed
	bedtools intersect -wa -a $i -b $NAME.repeats.bed | sort | uniq |wc -l > $NAME.collapsedRegions
	bedtools intersect -wa -a $i -b $NAME.repeats.bed | sort | uniq  > $NAME.collapsedRegions
	NO=$(cat $i | wc -l)
	OV=$(bedtools intersect -wa -a $i -b $NAME.repeats.bed | sort | uniq |wc -l)
	echo $NAME $NO $OV
done





#for line in $(cat test.test); do grep "^$line" ../../../7_lengthEstimation/at6137.lengthEstimate.tmp ; done | sort | uniq | wc -l
