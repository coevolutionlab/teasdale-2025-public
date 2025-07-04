#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
MINIM="/ebio/abt6/mcollenberg/miniconda3/bin/minimap2"


for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_mappings
	cd $NAME\_mappings
	$QSUB 20 1 $MINIM -x asm5 -t 20 /ebio/abt6_projects9/abt6_databases/db/genomes/athaliana/genome.fasta ../$i > $NAME.p_ctg.chrMchrC.PAF &
	cd ../
done
