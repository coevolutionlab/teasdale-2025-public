#!/bin/bash

echo "genotype,chr1,chr2,chr3,chr4,chr5" >> contigsPerChr.csv

for i in $(ls at*.bionano.hifiasm.scaffolds.agp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	CHR1=$(cat $i | awk '$1 ~/^Chr1/ && $5 == "U"' | wc -l)
	CHR2=$(cat $i | awk '$1 ~/^Chr2/ && $5 == "U"' | wc -l)
	CHR3=$(cat $i | awk '$1 ~/^Chr3/ && $5 == "U"' | wc -l)
	CHR4=$(cat $i | awk '$1 ~/^Chr4/ && $5 == "U"' | wc -l)
	CHR5=$(cat $i | awk '$1 ~/^Chr5/ && $5 == "U"' | wc -l)
	TOTAL=$(cat $i | awk '$1 ~/^Chr/ && $5 == "U"' | wc -l)
	echo $NAME $CHR1 $CHR2 $CHR3 $CHR4 $CHR5 $TOTAL
	echo $NAME $CHR1 $CHR2 $CHR3 $CHR4 $CHR5 $TOTAL >> gapsPerChr.4R
done

sed -i -e 's/ /;/g' gapsPerChr.4R

