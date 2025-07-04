#!/bin/bash

for i in $(ls at*.largeContigs100kb.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults_tair10
	cp ragtag.scaffold.stats $NAME.tair10.hifiasm.scaffolds.stats
	cd ../
done


for i in $(ls at*.largeContigs100kb.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_ragtagResults_bionano
        cp ragtag.scaffold.stats $NAME.bionano.hifiasm.scaffolds.stats
        cd ../
done
