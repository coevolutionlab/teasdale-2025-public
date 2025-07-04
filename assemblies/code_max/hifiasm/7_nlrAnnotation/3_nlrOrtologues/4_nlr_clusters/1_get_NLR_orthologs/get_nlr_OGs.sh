#!/bin/bash

for line in $(cat r_genes.full_set.list.updated20200321.csv); do
	ID=$(echo $line | awk -F',' '{print $1}')
	TYPE=$(echo $line | awk -F',' '{print $2}')
	grep $ID Orthogroups.txt >> NLR.tmp
done

cat NLR.tmp | sed 's/ /\n/g' | awk '$1 ~/^at/' > NLR.list
rm NLR.tmp

for i in $(cat accessions.txt); do
	grep $i NLR.list | awk -F'_' '{print $2}' | awk -F'.' '{print $1}' > $i.nlrOG.txt
done
