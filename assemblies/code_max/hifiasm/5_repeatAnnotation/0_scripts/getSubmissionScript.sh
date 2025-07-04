#!/bin/bash

for i in $(ls at*.scaffolds.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cp edta2Cluster.sh $NAME.edta2Cluster.sh
	sed -i -e "s/\$XXXZZZ/$NAME/g" $NAME.edta2Cluster.sh
done
