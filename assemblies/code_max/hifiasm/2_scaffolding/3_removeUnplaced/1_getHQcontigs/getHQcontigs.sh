#!/bin/bash


for line in $(cat names.txt); do
	NAME=$(echo $line)
	grep "$NAME" mq.tsv | awk '$3 ~/^Chr/ || $4 >= 30 {print $3}' | sort | uniq  > $NAME.mqAbove30.tsv
	NO=$(cat $NAME.mqAbove30.tsv | sort | uniq -c  | wc -l)
	cat $NAME.chrM.chrC.final.gff | 
	echo $NAME $NO
done

