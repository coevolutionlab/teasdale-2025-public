#!/bin/bash


for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.intact.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bedtools intersect -wa -a $i -b $NAME.edta.cleaned.gff > $NAME.intactTE.gff
done

for i in $(ls at*.intactTE.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '{print $3}' | sort | uniq > $NAME.te_types.tmp
	echo "type;length" > $NAME.teLength.4R
	for line in $(cat $NAME.te_types.tmp); do
		grep $line $i | awk -v pat=$line '{print pat, ($5-$4)}' | sed 's/ /;/g' >> $NAME.teLength.4R
	done
	rm $NAME.te_types.tmp
done
