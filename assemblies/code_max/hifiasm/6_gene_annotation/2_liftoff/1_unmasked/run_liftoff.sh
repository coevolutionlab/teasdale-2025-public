#!/bin/bash

source activate liftoff

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_liftoffResults
	cd $NAME\_liftoffResults
	ln -s ../TAIR10_GFF3_genes.gff ./
	ln -s ../TAIR10_chr_all.renamed.fas ./
	liftoff -exclude_partial -g TAIR10_GFF3_genes.gff -o $NAME.liftoff.gff -u $NAME.unmapped.txt -p 12 -copies ../$i TAIR10_chr_all.renamed.fas &
	cd ../
done
