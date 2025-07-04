#!/bin/bash

COORD="/ebio/abt6/mcollenberg/miniconda3/envs/mummer4/bin/show-coords"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"

for i in $(ls at*.hifiasm.chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_syriResults
	cd $NAME\_syriResults
	$COORD -THrd out.filtered.delta > out.filtered.coords &
 	cd ../
done

