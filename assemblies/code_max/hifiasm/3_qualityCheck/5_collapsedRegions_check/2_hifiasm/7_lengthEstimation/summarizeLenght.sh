#!/bin/bash

for i in $(ls at*lengthEstimate.tmp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME > $NAME.length.4R.tmp
	cat $i | awk '{print $6}' | awk -F'.' '{print $1}' >> $NAME.length.4R.tmp
done

paste at*.length.4R.tmp > lengthSummary.4R

sed -i -e 's/\t/;/g' lengthSummary.4R
rm at*.length.4R.tmp
sed -i -e 's/\.//g' lengthSummary.4R
