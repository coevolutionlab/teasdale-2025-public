#!/bin/bash

source activate bcftools

for i in $(ls at*calls.bcf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bcftools view --threads 10 $i > $NAME.calls.vcf &
	echo $NAME
done
