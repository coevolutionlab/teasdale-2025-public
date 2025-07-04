#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
SAM="/ebio/abt6_projects9/abt6_software/bin/samtools/bin/samtools"

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_mappings
	$QSUB 4 1 $SAM view -@ 4 -S -b -o $NAME.mappings.hifiasm.scaffolds.bam $NAME.mappings.hifiasm.scaffolds.sam &
	cd ../
done
