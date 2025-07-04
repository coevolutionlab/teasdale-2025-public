#!/bin/bash

for i in $(ls at*.primaryContigs.superkingdom.at*.primaryContigs.hifiasm.blobplot.blobDB.table.txt); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	CLEAN=$(cat $i | awk '$1 !~/^#/' | awk '$6 != "Bacteria" && $6 != "Viruses" {print $1}' | wc -l)
	cat $i | awk '$1 !~/^#/' | awk '$6 != "Bacteria" && $6 != "Viruses" {print $1}' > $NAME.cleanContigs
	TOTAL=$(cat $i | awk '$1 !~/^#/'| wc -l)
	echo $NAME $CLEAN $TOTAL
done
