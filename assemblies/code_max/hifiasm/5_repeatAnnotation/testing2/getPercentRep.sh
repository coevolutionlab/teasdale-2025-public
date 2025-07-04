#!/bin/bash

for i in $(ls at*.repeatAnnotation.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^#/ && $1 !~/^Chr/ {print $1}' | sort | uniq > $NAME.unplacedContig.ids
	seqtk comp $NAME.scaffolds.bionano.hifiasm.final.fasta | awk '{print $1, $2}' > $NAME.comp
	for line in $(cat $NAME.unplacedContig.ids); do
		grep $line $i > $NAME.$line.tmp
		cat $NAME.$line.tmp | awk '{print $5-$4}' | awk '{sum+=$1} END {print sum}' > $NAME.$line.occupied
		grep $line $NAME.comp | awk '{print $2}' >> $NAME.$line.totalLength
		paste $NAME.$line.occupied $NAME.$line.totalLength >> $NAME.overview.tmp
		rm $NAME.$line.occupied
		rm $NAME.$line.totalLength
		rm $NAME.$line.tmp
	done
	cat $NAME.overview.tmp | awk '$3=100*$1/$2' >$NAME.final
	rm $NAME.overview.tmp
done
