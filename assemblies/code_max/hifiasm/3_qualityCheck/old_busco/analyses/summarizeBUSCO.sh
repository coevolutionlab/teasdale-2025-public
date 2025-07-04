#!/bin/bash

for i in $(ls short*at*.txt); do
	NAME=$(echo $i | awk -F'.' '{print $4}' | awk -F'_' '{print $1}')
	cat $i | awk -F'[Sn]' '{print $2}' | awk '$1 ~/^:/' | sed 's/://g' | sed 's/%,D/;/g' | sed 's/%],F/;/g' | sed 's/%,M/;/g' | sed "s/%,/;$NAME/g" >> $NAME.stats.tmp
	cat $NAME.stats.tmp | awk -F';' '{print $5, $1, $2, $3, $4}' >> $NAME.stats
	rm $NAME.stats.tmp
done

cat at*.stats >> buscoSummary.4R
sed -i '1i genotype single duplicated fragmented missing' buscoSummary.4R
rm at*.stats
