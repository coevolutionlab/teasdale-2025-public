#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.mod.EDTA.TEanno.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME
	for line in $(cat $i | awk '$1 !~/^#/ {print $3}' | sort | uniq); do
		cat $i | grep $line | awk '{print ($5-$4)}' | awk -v pat="$line" '{s+=$1;}END{print "all",pat,s}' >> $NAME.sum.tmp
		cat $NAME.edta.cleaned.gff | grep $line | awk '{print ($5-$4)}' | awk -v pat="$line" '{s+=$1;}END{print "clean", pat,s}' >> $NAME.sum.tmp
		cat $NAME.edta.cleaned.gff | grep $line | awk '$1 ~/^Chr/ {print ($5-$4)}' | awk -v pat="$line" '{s+=$1}END{print "cleanPlaced", pat,s}' >> $NAME.sum.tmp
		echo $line
	done
done

echo "name;type;length" > repeatSummary.4R
echo "name;type;length" > repeatSummary.nocleanup.4R
echo "name;type;length" > repeatSummary.placed.4R

for i in $(ls at*.sum.tmp); do
	NAME=$(echo $i | awk -F'.' '{print $1}' | sed 's/at/AT/g')
	cat $i | awk -v pat="$NAME" '$1 =="clean" {print pat, $2, $3}' >> repeatSummary.4R
	cat $i | awk -v pat="$NAME" '$1 =="all" {print pat, $2, $3}' >> repeatSummary.nocleanup.4R
	cat $i | awk -v pat="$NAME" '$1 =="cleanPlaced" {print pat, $2, $3}' >> repeatSummary.placed.4R
	echo $NAME "done"
	rm $i
done

sed -i -e 's/ /;/g' repeatSummary.4R
sed -i -e 's/ /;/g' repeatSummary.nocleanup.4R 
sed -i -e 's/ /;/g' repeatSummary.placed.4R 

