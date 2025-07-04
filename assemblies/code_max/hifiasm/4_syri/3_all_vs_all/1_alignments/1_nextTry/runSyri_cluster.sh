#!/bin/bash

source activate syri
PATH_TO_SYRI="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/syri"
PATH_TO_PLOTSR="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/plotsr"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
PYTHON="/ebio/abt6/mcollenberg/miniconda3/envs/syri/bin/python3"

#nice -n10 minimap2 -t 250 -ax asm5 --eqx genome.fasta at9900.ragtag.scaffolds.subset.fasta > at9900_tair10.sam
#python

#python3 $PATH_TO_SYRI -c at9900_tair10.sam -r genome.fasta -q at9900.ragtag.scaffolds.subset.fasta -k -F S
#python3 $PATH_TO_PLOTSR syri.out refgenome qrygenome -H 8 -W 5

for i in $(find -name "at*_alignments" -type d); do
	NAME=$(echo $i | awk -F'_' '{print $1}')
	cd $i
	echo $i 
	for file in $(ls at*_vs_at*.sam); do
		NAME2=$(echo $file | awk -F'_' '{print $3}' | awk -F'.' '{print $1}')
		OUTNAME=$(echo $file | awk -F'.' '{print $1}')
		mkdir $OUTNAME\_syri
		cd $OUTNAME\_syri
		$QSUB 10 2 $PYTHON $PATH_TO_SYRI -c ../$file -r ../../$NAME.hifiasm.chr1to5.fasta -q ../../$NAME2.hifiasm.chr1to5.fasta --prefix $OUTNAME. -k -F S &
		cd ../
	done 
	cd ../
done


