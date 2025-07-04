#!/bin/bash

for i in $(ls at*.scaffolds.fasta)l; do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	bcftools mpileup --threads 10 -D -Q5 --max-BQ 50 -F0.1 -o25 -e1 --delta-BQ 10 -M99999 -f at9900.scaffolds.fasta $NAME.mappings.falcon.scaffolds.sorted.bam | bcftools call -mv -Ob -o $NAME.calls.bcf &
done

