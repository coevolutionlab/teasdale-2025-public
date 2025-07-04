#!/bin/bash

PATH_TO_SYRI="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/syri"
PATH_TO_PLOTSR="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/plotsr"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
NUCMER="/ebio/abt6/mcollenberg/miniconda3/envs/mummer4/bin/nucmer"

for line in $(cat alignment.list); do
	NAME=$(echo $line | awk -F'.' '{print $1}')
	NAME1=$(echo $line | awk -F';' '{print $1}')
	NAME2=$(echo $line | awk -F';' '{print $2}')
	NAME3=$(echo $line | awk -F';' '{print $2}' | awk -F'.' '{print $1}')
	mkdir $NAME\_alignments
	cd $NAME\_alignments
	mkdir $NAME\_vs_$NAME3
	cd $NAME\_vs_$NAME3
	$QSUB 10 2 $NUCMER -t 10 --maxmatch -l 40 -g 90 -b 100 -c 200 ../../$NAME1 ../../$NAME2 
 	cd ../../
done




















