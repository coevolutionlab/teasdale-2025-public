#!/bin/bash

rm at*.*.bed

#for file in $(ls at*.scaffolds.bionano.final.fasta); do
#	NAME=$(echo $file | awk -F'.' '{print $1}')
#	seqtk comp $file | awk '$1 ~/^Chr/ {print $1, $2}' | sed 's/\_RagTag\_RagTag//g' | sed 's/ /\t/g' > $NAME.genome.index
#	cat $NAME.genome.index | awk '{print $1, "0", $2}' | sed 's/ /\t/g' > $NAME.genome.4circus
#	bedtools makewindows -w 100000 -g $NAME.genome.index > $NAME.windows.bed
#done


for file in $(ls at*.syri.out); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	for line in $(cat svTypes.reduced.list); do
		grep -w $line $file | awk '$1 !~/^-/ {print $1, $2, $3}' | sed 's/ /\t/g' >> $NAME.$line.bed
	done
done


for line in $(cat svTypes.reduced.list); do
	for file in $(ls at*.$line.bed); do
		NAME=$(echo $file | awk -F'.' '{print $1}')
		bedtools intersect -c -a tair10.windows -b $file > $NAME.$line.4circos
		echo $NAME $line "done"
	done
done


for i in $(cat chr.list); do
	for file in $(ls at*.NOTAL.4circos); do
		NAME=$(echo $file | awk -F'.' '{print $1}')
		echo $NAME $NAME > $NAME.$i.list
		grep $i $file | awk '{print $2, $4}' >> $NAME.$i.list
	done
	paste at*.$i.list | awk '{print $1, $2, $4, $6, $8, $10, $12, $14, $16, $18, $20, $22, $24, $26, $28, $30, $32, $34, $36}' > $i.final.list
	sed -i -e '0,/at6137/{s/at6137/position/}' $i.final.list
	sed -i -e 's/ /;/g' $i.final.list
	sed -i -e 's/at/AT/g' $i.final.list
done








sed -i '1ichr\tstart\tend\tvalue1' at*.*.4circos
