#!/bin/bash

for i in $(ls at*.edta_clean.filtered.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo "genotype,type,length" > $NAME.edta.cleaned.filtered.summary
	for line in $(cat $i | awk '$1 !~/^#/ {print $3}' | sort | uniq); do
		grep -w "$line" $i | awk '{print ($5-$4)}' | awk -v pat="$line" -v name="$NAME" '{sum+=$1} END {print name, pat, sum}' >> $NAME.edta.cleaned.filtered.summary
	done 
	echo $NAME "processed"
done

cat at*.edta.cleaned.filtered.summary | awk '$1 !~/^genotype/' > repeatSummaryFilteredCleaned.4R
sed -i -e 's/ /;/g' repeatSummaryFilteredCleaned.4R
