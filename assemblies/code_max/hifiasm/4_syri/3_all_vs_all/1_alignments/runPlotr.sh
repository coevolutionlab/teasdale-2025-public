#!/bin/bash

source activate syri
PATH_TO_SYRI="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/syri"
PATH_TO_PLOTSR="/ebio/abt6_projects7/diffLines_20/code/tools/syri-master/syri/bin/plotsr"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
PYTHON="/ebio/abt6/mcollenberg/miniconda3/envs/syri/bin/python3"


#for i in $(cat alignment.list); do
#	NAME=$(echo $i | awk -F'_' '{print $1}')
#	cd $i
#	echo $i 
#	for file in $(find . -name "at*_syri" -type d); do
#		NAME2=$(echo $file | awk -F'_' '{print $3}')
#		OUTNAME=$(echo $file | awk -F'.' '{print $1}')
#		cd $OUTNAME\_syri
#		$QSUB 5 1 $PYTHON $PATH_TO_PLOTSR $NAME\_vs_$OUTNAME.syri.out ../../$NAME.hifiasm.chr1to5.fasta ../../$OUTNAME.hifiasm.chr1to5.fasta -H 8 -W 5 
#		cd ../
#	done 
#	cd ../
#done

for NAME in $(cat alignment.list | awk -F'.' '{print $1}' | sort | uniq); do
	echo $NAME
	cd $NAME\_alignments
	for i in $(cat ../alignment.list | awk -v name="$NAME" -F'.' '$1 ~ name {print}'); do
		NAME2=$(echo $i | awk -F';' '{print $2}' | awk -F'.' '{print $1}')
		cd $NAME\_vs_$NAME2\_syri
		echo $i
		echo $NAME2
		$QSUB 5 1 $PYTHON $PATH_TO_PLOTSR $NAME\_vs_$NAME2.syri.out ../../$NAME.hifiasm.chr1to5.fasta ../../$NAME2.hifiasm.chr1to5.fasta -H 8 -W 5
		cd ../
	done
	cd ../
done


