#!/bin/bash

for i in $(ls at*.repeatAnnotation.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | sed 's/Target "/Target:"/g' | awk '{print $1, $4, $5, $2, $3, $9}' | sed 's/ /\t/g'  > $NAME.repeatAnnotation.bed
	cat $NAME.snp.summary.final | awk '{print $1, $2, $3}' | sed 's/ /\t/g'>  $NAME.snp.bed
	bedtools intersect -wb -a $NAME.snp.bed -b $NAME.repeatAnnotation.bed > $NAME.repeat_snp.intersection.txt 
	bedtools intersect -wa -a $NAME.snp.bed -b $NAME.repeatAnnotation.bed > $NAME.snp_repeat.intersection.txt
	echo $NAME "done"
	NO_total=$(cat $NAME.snp.summary.final | wc -l)
	NO_intersect=$(cat $NAME.snp_repeat.intersection.txt | sort | uniq | wc -l)
	echo $NAME $NO_total $NO_intersect > $NAME.snpInRepeats_vs_totalSNP.txt
#	rm $NAME.repeatAnnotation.bed
#	rm $NAME.snp.bed
done


cat at*.snpInRepeats_vs_totalSNP.txt > total_vs_annotatedSNPclusters.txt
rm at*.snpInRepeats_vs_totalSNP.txt
