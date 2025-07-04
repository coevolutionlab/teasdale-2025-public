#!/bin/bash

source activate syri
PATH_TO_SYRI="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/syri"
PATH_TO_PLOTSR="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/plotsr"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"

#nice -n10 minimap2 -t 250 -ax asm5 --eqx genome.fasta at9900.ragtag.scaffolds.subset.fasta > at9900_tair10.sam
#python

#python3 $PATH_TO_SYRI -c at9900_tair10.sam -r genome.fasta -q at9900.ragtag.scaffolds.subset.fasta -k -F S
#python3 $PATH_TO_PLOTSR syri.out refgenome qrygenome -H 8 -W 5

for i in $(ls at*.hifiasm.chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_syriResults
	cd $NAME\_syriResults
	$QSUB 20 1 minimap2 -t 20 -ax asm5 --eqx ../TAIR10.chr1to5.fasta ../$i -o $NAME\.hifiasm_vs_tair10.sam &
 	cd ../
done

