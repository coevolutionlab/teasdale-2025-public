#!/bin/bash

for line in $(cat chr.list); do
	grep $line tair10.nlr.map > $line.tair10.nlr.map
	sed -i -e "s/$line/TAIR10/g" $line.tair10.nlr.map
	cat $line.tair10.nlr.map $line.nlrMapSummary.4R > $line.nlrMapSummary.final.4R.tmp
	grep $line tair10.chrSize.txt > $line.tair10.chrSize.txt
	sed -i -e "s/$line/TAIR10/g" $line.tair10.chrSize.txt
	cat $line.tair10.chrSize.txt $line.sizeSummary.4R > $line.sizeSummary.4R.tmp
	cat $line.nlrMapSummary.final.4R.tmp | sort | uniq | awk '$1 !~/^chrom/'| sed 's/ /\t/g' > $line.nlrMapSummary.final.4R
	sed -i '1ichrom\tstart\tend\tfeature' $line.nlrMapSummary.final.4R
	cat $line.sizeSummary.4R.tmp | sort | uniq > $line.sizeSummary.final.4R
	rm $line.nlrMapSummary.final.4R.tmp $line.sizeSummary.4R.tmp
done

