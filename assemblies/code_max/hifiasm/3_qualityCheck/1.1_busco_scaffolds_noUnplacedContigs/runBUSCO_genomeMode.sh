#!/bin/bash

source activate busco2

export PATH="/ebio/abt6/mcollenberg/miniconda3/envs/busco2/bin:$PATH"
export PATH="/ebio/abt6/mcollenberg/miniconda3/envs/busco2/config:$PATH"


for i in $(ls at*.scaffolds.bionano.final.fasta); do
	NAME=$(echo $i | awk -F"." '{print $1}')
	mkdir $NAME\_buscoOUT
	cd $NAME\_buscoOUT
	busco -m genome -i ../$i -o $NAME\_buscoResults -l embryophyta_odb10 -c 125 
	cd ../
done
