#!/bin/bash

for i in $(ls at*.chrM.chrC.final.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk -F':' '$3 >=30' | awk '{print $1}' > $NAME.organellarContigs.list
	ORGANELLAR=$(cat $i | awk -F':' '$3 >=30' | awk -F';' '{print $5}' | awk -F':' '{sum+=$2} END {print sum}')
	for line in $(cat $NAME.organellarContigs.list); do
		cp $NAME.repeatsUnplacedContigs.gff $NAME.repeatsUnplacedContigs.gff.tmp
		sed -i "/^$line/d" $NAME.repeatsUnplacedContigs.gff.tmp
		cp $NAME.TEsUnplacedContigs.gff $NAME.TEsUnplacedContigs.gff.tmp
		sed -i "/^$line/d" $NAME.TEsUnplacedContigs.gff.tmp
	done &
	echo $NAME "done"
done
