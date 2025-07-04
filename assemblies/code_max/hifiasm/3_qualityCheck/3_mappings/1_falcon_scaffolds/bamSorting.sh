#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
SAM="/ebio/abt6_projects9/abt6_software/bin/samtools/bin/samtools"

for i in $(ls at*.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_mappings
	$QSUB 20 1 $SAM sort -@ 20 -o $NAME.mappings.falcon.scaffolds.sorted.bam $NAME.mappings.falcon.scaffolds.bam &
	cd ../
done
