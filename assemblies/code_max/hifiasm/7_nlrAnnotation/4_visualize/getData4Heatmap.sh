#!/bin/bash

for i in $(ls at*.nlr.liftoff.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
#	seqtk comp $i | head -n5 | awk '{print $1, $2}' | sed 's/\_RagTag\_RagTag//g' | sed 's/ /\t/g' > $NAME.chrSize.txt
	cat $NAME.nlr.liftoff.gff | awk '$3 == "gene" {print}' | grep 'NLR='  |  awk '{print $1, $4, $5, "gene"}' | sed 's/\_RagTag\_RagTag//g' |sed 's/ /\t/g' > $NAME.nlr.map
	sed -i '1ichrom	start	end	feature' $NAME.nlr.map
done

