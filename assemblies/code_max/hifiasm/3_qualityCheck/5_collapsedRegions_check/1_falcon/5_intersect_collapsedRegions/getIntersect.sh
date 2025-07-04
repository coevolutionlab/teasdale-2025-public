#!/bin/bash

for i in $(ls at*.repeatAnnotation.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '{print $1, $4, $5}' | sed 's/ /\t/g'  > $NAME.repeatAnnotation.bed
	cat $NAME.snp.summary.final | awk '{print $1, $2, $3}' | sed 's/ /\t/g' $NAME.snp.bed
	bedtools intersect 
