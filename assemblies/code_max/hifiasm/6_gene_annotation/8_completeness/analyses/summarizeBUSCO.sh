#!/bin/bash

echo "single" > categories.tmp
echo "duplicated" >> categories.tmp
echo "fragmented" >> categories.tmp
echo "missing" >> categories.tmp

for i in $(ls short*at*.txt); do
	NAME=$(echo $i | awk -F'.' '{print $4}' | awk -F'_' '{print $1}')
	cat $i | awk -F'[Sn]' '{print $2}' | awk '$1 ~/^:/' | sed 's/://g' | sed 's/%,D/;/g' | sed 's/%],F/;/g' | sed 's/%,M/;/g' | sed "s/%,/;$NAME/g" >> $NAME.stats.tmp
	cat $NAME.stats.tmp | awk -F';' '{print $5, $1, $2, $3, $4}' >> $NAME.stats
	cat $NAME.stats.tmp | awk -F';' '{print $1}' > $NAME.stats.4R
	cat $NAME.stats.tmp | awk -F';' '{print $2}' >> $NAME.stats.4R
	cat $NAME.stats.tmp | awk -F';' '{print $3}' >> $NAME.stats.4R
	cat $NAME.stats.tmp | awk -F';' '{print $4}' >> $NAME.stats.4R	
#	rm $NAME.stats.tmp
	paste categories.tmp $NAME.stats.4R > $NAME.stats.4R.tmp
	sed -i -e 's/\t/;/g' $NAME.stats.4R.tmp
	rm $NAME.stats.tmp
	rm $NAME.stats.4R
	mv $NAME.stats.4R.tmp $NAME.stats.4R
done

cat at*.stats > buscoSummary.4R
sed -i '1i genotype single duplicated fragmented missing' buscoSummary.4R
rm at*.stats
