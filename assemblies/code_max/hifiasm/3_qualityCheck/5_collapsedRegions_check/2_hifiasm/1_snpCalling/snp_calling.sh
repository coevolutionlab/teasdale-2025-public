#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
BCF="/ebio/abt6/mcollenberg/miniconda3/envs/bcftools/bin/bcftools"

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME
	mkdir $NAME\_snpCalling
	cd $NAME\_snpCalling
	bcftools mpileup --threads 10 -D -Q5 --max-BQ 50 -F0.1 -o25 -e1 --delta-BQ 10 -M99999 -f ../$i ../$NAME.mappings.hifiasm.scaffolds.sorted.bam | bcftools call -mv -Ob -o $NAME.calls.bcf &
	cd ../
done

