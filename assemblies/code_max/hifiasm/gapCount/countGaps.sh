#!/bin/bash

for i in $(ls at*.hifiasm.scaffolds.agp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	FALCON=$(cat $NAME.scaffolds.agp | awk '$5 == "U"' | wc -l)
	HIFIASM=$(cat $NAME.hifiasm.scaffolds.agp | awk '$5 == "U"' | wc -l)
	echo $NAME "Falcon" $FALCON
	echo $NAME "HifiASM" $HIFIASM
done
