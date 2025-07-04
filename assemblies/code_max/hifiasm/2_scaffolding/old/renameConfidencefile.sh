#!/bin/bash

for i in $(ls at*.largeContigs100kb.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults_tair10
	cp ragtag.confidence.txt $NAME.tair10.hifiasm.confidence.txt
	cd ../
done


for i in $(ls at*.largeContigs100kb.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_ragtagResults_bionano
        cp ragtag.confidence.txt $NAME.bionano.hifiasm.confidence.txt
        cd ../
done
