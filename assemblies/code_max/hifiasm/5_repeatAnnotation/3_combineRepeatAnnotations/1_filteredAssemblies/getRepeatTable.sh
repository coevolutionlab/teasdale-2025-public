#!/bin/bash

cat at*.edta_clean.filtered.gff | awk '{print $3}' | sort | uniq > types.list

rm at*.*.tmp

for i in $(ls at*.edta_clean.filtered.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	for line in $(cat types.list); do
		grep -w "$line" $i | awk '{print ($5-$4)}' | awk -v name="$NAME" -v type="$line" '{sum+=$1} END {print name, sum}' >> $NAME.$line.tmp
	done 
done

for line in $(cat types.list); do
	echo $line
	echo "genotype" $line > TE.$line.list.tmp
	cat at*.$line.tmp >> TE.$line.list.tmp
	rm at*.$line.tmp
done

paste TE.*.list.tmp | awk 'OFS=";" {print $1, $2, $4, $6, $8, $10, $12, $14}' > TE.final.summary.csv
