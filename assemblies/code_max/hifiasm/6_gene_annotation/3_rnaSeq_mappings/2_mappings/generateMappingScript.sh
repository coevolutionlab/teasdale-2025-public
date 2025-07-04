#!/bin/bash

for i in $(ls at*.bionano.hifiasm.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cp templateMappingScript.sh $NAME.StarMappingScript.sh
	sed -i -e "s/ACCNAME/$NAME/g" $NAME.StarMappingScript.sh
done
