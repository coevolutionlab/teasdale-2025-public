#!/bin/bash

for i in $(ls at*.softmasked.final.gff3); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$3 == "gene" {print}' | awk '{print $1, $4, $5, "gene"}' | sed 's/\_RagTag\_RagTag//g' |sed 's/ /\t/g' > $NAME.gene.map
	sed -i '1ichrom	start	end	feature' $NAME.gene.map
done

