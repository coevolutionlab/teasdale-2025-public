#!/bin/bash

#for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta); do 
#	NAME=$(echo $i | awk -F'.' '{print $1}')
#	seqtk comp $i > $NAME.length
#	echo $NAME "done"
#done


for i in $(ls at*.contigs2keep); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	for line in $(cat $i); do
		grep "$line" $NAME.length >> $NAME.length.tmp
	done
	LENGTH_UN=$(cat $NAME.length.tmp | awk '$1 !~/^Chr/ {sum+=$2} END {print sum}')
	NO_UN=$(cat $NAME.length.tmp | awk '$1 !~/^Chr/' | wc -l)
	LENGTH_TOT=$(cat $NAME.length.tmp | awk '{sum+=$2} END {print sum}')
	NO_TOT=$(grep '>' $NAME.*final.fasta | wc -l)
	echo $NAME $NO_TOT $NO_UN $LENGTH_UN $LENGTH_TOT
	rm $NAME.length.tmp
done
