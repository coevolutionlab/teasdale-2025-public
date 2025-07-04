#!/bin/bash

DELTA="/ebio/abt6/mcollenberg/miniconda3/envs/mummer4/bin/delta-filter"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"

for i in $(ls at*.hifiasm.chr1to5.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_syriResults
	$QSUB 5 1 $DELTA -m -i 90 -l 100 out.delta > out.filtered.delta
        cd ../
done




