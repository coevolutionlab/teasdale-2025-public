#!/bin/bash

QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"

for i in $(ls at*.protein.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_blastOUT
	cd $NAME\_blastOUT
	$QSUB 30 2 blastp -query ../$i -db ../proteins.fasta -outfmt 6 -num_threads 30 -out $NAME\_blastp.out
	cd ../
done
