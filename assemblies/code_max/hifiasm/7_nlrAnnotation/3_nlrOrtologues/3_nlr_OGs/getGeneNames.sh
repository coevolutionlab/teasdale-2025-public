#!/bin/bash

rm nlr.geneCounts.4R

for line in $(cat nlrOGs.list); do
	grep $line orthogroups.txt | awk -F';' '{print $1,$2}' | awk -F',' '{print $1}' | sed 's/Araport\_//g' | awk -F'.' '{print $1}' | sed 's/ /;/g' >> nlrGene.names
done

for line in $(cat nlrGene.names); do
	OG=$(echo $line | awk -F';' '{print $1}')
	NAME=$(echo $line | awk -F';' '{print $2}')
	COUNT=$(grep $OG orthogroups.geneCount.csv | sed 's/;/ /g')
	echo $OG $NAME $COUNT >> nlr.geneCounts.tmp
done

rm nlrGene.names

cat nlr.geneCounts.tmp | cut --complement -d' ' -f1,3 > nlr.geneCounts.4R
