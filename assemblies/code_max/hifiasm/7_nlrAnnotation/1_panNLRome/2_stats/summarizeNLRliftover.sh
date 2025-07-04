#!/bin/bash

echo "genotype;nlrTotal;Chr1;Chr2;Chr3;Chr4;Chr5;unplacedContig"

for i in $(ls at*.liftoff.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	NLR=$(cat $i | awk '$3 == "gene"' | grep 'NLR=' | wc -l)
	Chr1=$(cat $i | awk '$3 == "gene"' | grep 'NLR=' | awk '$1 ~/^Chr1/' | wc -l)
	Chr2=$(cat $i | awk '$3 == "gene"' | grep 'NLR=' | awk '$1 ~/^Chr2/' | wc -l)
	Chr3=$(cat $i | awk '$3 == "gene"' | grep 'NLR=' | awk '$1 ~/^Chr3/' | wc -l)
	Chr4=$(cat $i | awk '$3 == "gene"' | grep 'NLR=' | awk '$1 ~/^Chr4/' | wc -l)
	Chr5=$(cat $i | awk '$3 == "gene"' | grep 'NLR=' | awk '$1 ~/^Chr5/' | wc -l)
	UNPLACED=$(cat $i | awk '$3 == "gene"' | grep 'NLR=' | awk '$1 !~ /^Chr/' | wc -l)
	echo $NAME $NLR $Chr1 $Chr2 $Chr3 $Chr4 $Chr5 $UNPLACED |sed 's/ /;/g' | sed 's/at/AT/g'
done
