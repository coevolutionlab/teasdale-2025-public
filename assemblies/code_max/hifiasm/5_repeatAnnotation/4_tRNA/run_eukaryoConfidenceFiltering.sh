#!/bin/bash

source activate trnascan

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME
	mkdir $NAME\_out
	EukHighConfidenceFilter --remove -s $NAME.tRNA.structure -i $NAME.tRNA.txt -o $NAME\_out -p $NAME.tRNA.filtered &
done



#echo "Filtering High Confidence tRNAs..."
#EukHighConfidenceFilter --remove \
#        -i $outputTMP/$ACC.tRNA.txt \
#        -s $outputTMP/$ACC.tRNA.struct \
#        -o $outputTMP -p /$ACC.tRNA




