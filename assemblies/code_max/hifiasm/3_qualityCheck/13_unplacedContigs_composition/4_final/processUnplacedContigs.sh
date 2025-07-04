#!/bin/bash

for i in $(ls at*.repeatAnnotation.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^Chr/ {print}' > $NAME.repeatAnnotation.unplacedContigs.gff
done


for i in $(ls at*.repeatAnnotation.unplacedContigs.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools intersect -v -b $i -a $NAME.chrM.chrC.final.gff > $NAME.chrM.chrC.v.gff
	cat $i $NAME.chrM.chrC.v.gff > $NAME.final.gff
	NO1=$(cat $NAME.final.gff | awk '$1 !~/^#/ {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	bedtools intersect -v -a $i -b $NAME.chrM.chrC.final.gff > $NAME.repeatAnnotation.v.gff
	NO2=$(cat $NAME.repeatAnnotation.v.gff | awk '$1 !~/^#/ {print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	echo $NAME $NO1 $NO2
done
