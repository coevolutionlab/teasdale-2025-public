#!/bin/bash
DELTA="/ebio/abt6/mcollenberg/miniconda3/envs/mummer4/bin/delta-filter"

for i in $(ls at*.hifiasm.chr1to5.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_syriResults
	$DELTA -m -i 90 -l 100 out.delta > out.filtered.delta &
        cd ../
done
