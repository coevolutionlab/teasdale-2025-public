#!/bin/bash

for i in $(ls at*.edta.cleaned.filtered.summary); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	TE=$(cat $i | awk '$1 !~/^genotype/ {print}' | awk -v name="$NAME" '{sum+=$3} END {print name, sum}')
	SIZE=$(seqtk comp $NAME.scaffolds.bionano.final.fasta | awk '{sum+=$2} END {print sum}')
	echo $TE $SIZE
done
