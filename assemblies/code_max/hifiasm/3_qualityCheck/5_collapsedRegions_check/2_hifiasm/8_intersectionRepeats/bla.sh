#!/bin/bash

for i in $(ls at*.snp.bed); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $NAME.repeatAnnotation.gff | awk '$1 ~/^Chr/ && $2 == "RepeatMasker"' > $NAME.repeats.bed
	bedtools intersect -wa -a $i -b $NAME.repeats.bed | sort | uniq |wc -l > $NAME.collapsedRegions
	bedtools intersect -wa -a $i -b $NAME.repeats.bed | sort | uniq  > $NAME.collapsedRegions
	NO=$(cat $i | wc -l)
	OV=$(bedtools intersect -wa -a $i -b $NAME.repeats.bed | sort | uniq |wc -l)
	echo $NAME $NO $OV
	cat $NAME.lengthEstimate.tmp | sed 's/\t/;/g' > $NAME.length2grep
	sed -i -e 's/\t/;/g' $NAME.collapsedRegions
	echo $NAME > $NAME.overlapLength
	for line in $(cat $NAME.collapsedRegions); do
		grep "^$line" $NAME.length2grep | sort | uniq >> $NAME.overlapLength
	done
	for i in $(ls $NAME.overlapLength); do
		cat $i | awk -F';' '$1 !~/^at/ {sum+=$6} END {print $1, sum}'
	done
done

#cat at*.test | awk -F';' '$1 !~/^at/ {sum+=$6} END {print $1, sum}' > test.test





#for line in $(cat test.test); do grep "^$line" ../../../7_lengthEstimation/at6137.lengthEstimate.tmp ; done | sort | uniq | wc -l
