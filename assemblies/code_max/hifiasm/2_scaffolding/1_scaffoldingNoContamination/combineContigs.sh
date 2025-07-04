#!/bin/bash

for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults_bionano
	mv ragtag.scaffold.fasta $NAME.scaffolds.fasta
	cat $NAME.scaffolds.fasta ../$NAME.smallContigs.u100kb.fasta > $NAME.scaffolds.bionano.hifiasm.final.fasta
	cd ../
	cd $NAME\_ragtagResults_tair10
	mv ragtag.scaffold.fasta $NAME.scaffolds.fasta
        cat $NAME.scaffolds.fasta ../$NAME.smallContigs.u100kb.fasta > $NAME.scaffolds.tair10.hifiasm.final.fasta
	cd ../
	echo $NAME
done
