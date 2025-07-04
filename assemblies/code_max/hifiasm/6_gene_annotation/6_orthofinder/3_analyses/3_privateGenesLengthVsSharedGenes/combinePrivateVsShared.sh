#!/bin/bash

for i in $(ls at*.privateGenes.length); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	paste $i $NAME.allGenes.length | sed 's/\t/;/g' > $NAME.privateVsShared.length
done
