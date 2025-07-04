#!/bin/bash

rm *.counts.4R
rm NLR.*.overview.tmp

for line in $(cat r_genes.full_set.list.updated20200321.csv); do
	ID=$(echo $line | awk -F',' '{print $1}')
	TYPE=$(echo $line | awk -F',' '{print $2}')
#	grep $ID Orthogroups.csv | sed 's/;/\n/g' | awk -F'_' '{print $1}' | sort | uniq -c | awk 'NF==2'  > $ID.tmp
#	cat $ID.tmp | awk -v type="$TYPE" -v id="$ID" '{print $1, $2, type, id}' | sed 's/ /;/g' | sed 's/at/AT/g' >> $TYPE.counts.4R
	grep $ID Orthogroups.csv >> NLR.$TYPE.overview.tmp
	rm $ID.tmp
done

rm nlr.*.4R

for i in $(ls NLR.*.overview.tmp); do
	TYPE=$(echo $i | awk -F'.' '{print $2}')
	cat $i | sort | uniq > $TYPE.uniq.tmp
	for line in $(cat $TYPE.uniq.tmp); do
		TAIR=$(echo $line | sed 's/;/\n/g' | awk 'NF==1 && $1 ~/^Araport\_/ {print $1}')
		echo $TAIR >> nlr.$TYPE.4R
		echo $line | sed -e 's/;/\n/g' | awk 'NF==1' | awk -F'_' '{print $1}' | sort | uniq -c >> nlr.$TYPE.4R
	done
done
