#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
SAM="/ebio/abt6_projects9/abt6_software/bin/samtools/bin/samtools"

for i in $(ls at*.mappings.hifiasm.contigs.sam); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_mappings
	$QSUB 20 1 $SAM index -@ 20 $NAME.mappings.hifiasm.p_ctg.sorted.bam &
	cd ../
done
