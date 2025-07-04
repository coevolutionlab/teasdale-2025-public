#!/bin/bash

for i in $(ls at*.bionano.hifiasm.confidence.txt); do
	echo $i 
	NAME=$(echo $i | awk -F'.' '{print $1}' | sed 's/at/AT/g')
	echo $NAME
	SUF=$(echo $i | awk -F'.' '{print $2"."$3"."$4"."$5}')
	cp $i $NAME\.$SUF
done
