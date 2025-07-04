#!/bin/bash

for i in $(ls at*.largeContigs100kb.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults_tair10
	cp ragtag.scaffolds.agp $NAME.tair10.hifiasm.scaffolds.agp
	cd ../
done


for i in $(ls at*.largeContigs100kb.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_ragtagResults_bionano
        cp ragtag.scaffolds.agp $NAME.bionano.hifiasm.scaffolds.agp
        cd ../
done
