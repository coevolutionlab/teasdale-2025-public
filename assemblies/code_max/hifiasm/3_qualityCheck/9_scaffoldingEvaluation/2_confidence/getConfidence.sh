#!/bin/bash

for i in $(ls at*.bionano.hifiasm.confidence.txt); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk -v name=$NAME '{print name, $2, $3, $4}' | sed 's/ /;/g' >> $NAME.stats.4R
	sed -i '1d' $NAME.stats.4R
	GROUP=$(cat $i | awk '{print $2}')
	LOCATION=$(cat $i | awk '{print $3}')
	ORIENTATION=$(cat $i | awk '{print $4}')
	echo $NAME >> $NAME.grouping.tmp
	echo $NAME >> $NAME.location.tmp
	echo $NAME >> $NAME.orientation.tmp
	echo $GROUP | tr ' ' '\n' >> $NAME.grouping.tmp
	echo $LOCATION | tr ' ' '\n' >> $NAME.location.tmp
        echo $ORIENTATION | tr ' ' '\n' >> $NAME.orientation.tmp 
	cat $NAME.stats.4R | awk -F';' '{print $1, $2, $3, $4}' > $NAME.confidence.stats.4R

done

paste at*.grouping.tmp >> summary.grouping.4R
paste at*.location.tmp >> summary.location.4R
paste at*.orientation.tmp >> summary.orientation.4R

sed -i '2d' summary.*.4R
sed -i -e 's/\t/;/g' summary.*.4R
rm at*.grouping.tmp at*.location.tmp at*.orientation.tmp
