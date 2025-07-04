#!/bin/bash

cat mq.tsv | awk '{print $1}' | sort | uniq | awk '$1 ~/^at/' > names.txt

for line in $(cat names.txt); do
	NAME=$(echo $line)
	grep "$NAME" mq.tsv | awk '$3 ~/^Chr/ || $4 >= 30 {print $3}' | sort | uniq  > $NAME.mqAbove30.tsv
	grep "$NAME" mq.tsv | awk '$3 ~/^Chr/ || $4 >= 30 {print $3}' | sort | uniq  >> $NAME.mqAbove30.tsv
	cat $NAME.chrM.chrC.final.gff | awk -F':' '$3 >= 20 {print}' | awk '{print $1}' >> $NAME.mqAbove30.tsv
	seqtk comp $line.scaffolds.bionano.hifiasm.final.fasta | awk '$2 >= 50000 {print $1}' >> $NAME.mqAbove30.tsv
	NO=$(cat $NAME.mqAbove30.tsv | sort | uniq -c | awk '$1 == 3 {print}' | wc -l)
	cat $NAME.mqAbove30.tsv | sort | uniq -c | awk '$1 == 3 {print $2}' > $NAME.contigs2keep
	echo $NAME $NO
done
