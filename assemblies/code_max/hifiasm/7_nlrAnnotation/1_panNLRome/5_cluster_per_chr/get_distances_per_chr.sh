#!/bin/bash

for i in $(ls at*.nlr.liftoff.gff); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cat $i | grep 'NLR=' | awk '$3 == "gene" {print $1, $4, $5}' >> $NAME.tmp
        for chr in $(cat $NAME.tmp | awk -F'_' '$1 !~/^ptg/ {print $1}' | sort | uniq); do
                grep $chr $NAME.tmp > $NAME.$chr.tmp
                cat $NAME.$chr.tmp | awk '{print $2}' | sed -e '1d' > $NAME.$chr.start.tmp
                cat $NAME.$chr.tmp | awk '{print $3}' | sed -e '$d' > $NAME.$chr.end.tmp
                paste $NAME.$chr.start.tmp $NAME.$chr.end.tmp | awk '{print $1-$2}' > $NAME.$chr.distances
		echo $NAME $chr
        done
	rm $NAME.*tmp
	rm $NAME.summary.4R
	for file in $(ls $NAME.Chr*.distances); do
		chr=$(echo $file | awk -F'.' '{print $2}')
		TOTAL=$(cat $file | wc -l)
		CLUST=$(cat $file | awk '$1 <= 200000' | wc -l)
		echo $chr $TOTAL $CLUST >> $NAME.summary.4R
	done
done



