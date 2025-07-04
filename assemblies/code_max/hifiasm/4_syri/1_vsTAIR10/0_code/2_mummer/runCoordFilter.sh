#!/bin/bash


COORD="/ebio/abt6/mcollenberg/miniconda3/envs/mummer4/bin/show-coords"

for i in $(ls at*.hifiasm.chr1to5.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_syriResults
	$COORD -THrd out.filtered.delta > out.filtered.coords &
        cd ../
done
