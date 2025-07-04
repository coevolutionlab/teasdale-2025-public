#!/bin/bash

for i in $(ls at*.calls.vcf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	PLACED=$(bcftools view -m2 -M2 -v snps $i | awk '$1 !~ /^#/ && $1 ~/^Chr/' | wc -l)
	UNPLACED=$(bcftools view -m2 -M2 -v snps $i | awk '$1 !~ /^#/ && $1 !~/^Chr/' | wc -l)
	TOTAL=$(bcftools view -m2 -M2 -v snps $i | awk '$1 !~ /^#/' | wc -l)
	echo $NAME $TOTAL $PLACED $UNPLACED
done
