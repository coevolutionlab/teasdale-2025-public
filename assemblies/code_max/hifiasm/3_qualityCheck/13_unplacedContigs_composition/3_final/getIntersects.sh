#!/bin/bash


for i in $(ls at*.repeatsUnplacedContigs.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools intersect -v -b $i -a $NAME.chrM.chrC.final.gff > $NAME.repeats.vOrganellar.gff
	cat $i $NAME.repeats.vOrganellar.gff > $NAME.organellar.repeats.gff
	bedtools intersect -v -a $NAME.TEsUnplacedContigs.gff -b $NAME.organellar.repeats.gff > $NAME.TEs.vOrganellar.vRepeats.gff
	cat $NAME.organellar.repeats.gff $NAME.TEs.vOrganellar.vRepeats.gff > $NAME.unplacedContigAnnotation.gff
	NO=$(cat $NAME.unplacedContigAnnotation.gff | awk '{print ($5-$4)}' | awk '{sum+=$1} END {print sum}')
	echo $NAME $NO
done

