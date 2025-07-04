#!/bin/bash

for i in $(ls at*.reads.jf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME
	cd $NAME\_out
	mv model.txt $NAME.model.txt
	mv plot.log.png $NAME.plot.log.png
	mv plot.png $NAME.plot.png
	mv progress.txt $NAME.progress.txt
	mv summary.txt $NAME.summary.txt
	cd ../
done
