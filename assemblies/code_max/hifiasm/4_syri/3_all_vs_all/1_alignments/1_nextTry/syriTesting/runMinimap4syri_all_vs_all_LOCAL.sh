#!/bin/bash

source activate syri
PATH_TO_SYRI="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/syri"
PATH_TO_PLOTSR="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/plotsr"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
MINIMAP="/ebio/abt6/mcollenberg/miniconda3/envs/syn/bin/minimap2"

#nice -n10 minimap2 -t 250 -ax asm5 --eqx genome.fasta at9900.ragtag.scaffolds.subset.fasta > at9900_tair10.sam
#python

#python3 $PATH_TO_SYRI -c at9900_tair10.sam -r genome.fasta -q at9900.ragtag.scaffolds.subset.fasta -k -F S
#python3 $PATH_TO_PLOTSR syri.out refgenome qrygenome -H 8 -W 5

for line in $(cat alignment.list); do
	NAME=$(echo $line | awk -F'.' '{print $1}')
	NAME1=$(echo $line | awk -F';' '{print $1}')
	NAME2=$(echo $line | awk -F';' '{print $2}')
	NAME3=$(echo $line | awk -F';' '{print $2}' | awk -F'.' '{print $1}')
	mkdir $NAME\_alignments
	cd $NAME\_alignments
	$MINIMAP -t 40 -ax asm5 ../$NAME1 ../$NAME2 -o $NAME\_vs\_$NAME3.sam 
 	cd ../
done

