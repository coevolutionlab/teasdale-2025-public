#!/bin/bash

source activate bcftools

for i in $(ls at*.calls.vcf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	vcftools --vcf $i --out $NAME --extract-FORMAT-info GT | grep "0/1" &
done
