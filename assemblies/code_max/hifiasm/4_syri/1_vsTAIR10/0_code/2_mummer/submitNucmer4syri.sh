#!/bin/bash

PATH_TO_SYRI="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/syri"
PATH_TO_PLOTSR="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/plotsr"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
NUCMER="/ebio/abt6/mcollenberg/miniconda3/envs/mummer4/bin/nucmer"


for i in $(ls at*.hifiasm.chr1to5.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_syriResults
	cd $NAME\_syriResults
	$QSUB 20 2 $NUCMER -t 20 --maxmatch -l 40 -g 90 -b 100 -c 200 ../TAIR10.chr1to5.fasta ../$NAME.hifiasm.chr1to5.fasta &
 	cd ../
done

