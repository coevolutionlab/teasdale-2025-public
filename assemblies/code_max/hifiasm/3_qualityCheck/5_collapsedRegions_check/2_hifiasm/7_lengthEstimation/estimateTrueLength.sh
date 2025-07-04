#!/bin/bash

for i in $(ls at*.samtools.depth); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	COVERAGE=$(cat $i | awk -F'= ' '{print $2}')
	cat $NAME.snp.summary.final | awk -v coverage="$COVERAGE" 'OFS="\t" {print $1, $2, $3, $4, $5, (($4/coverage)*5000)}' > $NAME.lengthEstimate.tmp
	cat $NAME.lengthEstimate.tmp | awk '{sum+=$6} END {print sum}' > $NAME.trueLength
	cat $NAME.lengthEstimate.tmp | awk '{sum+=$5} END {print sum}' > $NAME.snpSum
	cat $NAME.snp.summary.final | wc -l > $NAME.regionSum
	paste $NAME.trueLength $NAME.snpSum $NAME.regionSum | awk -v name=$NAME 'OFS="\t" {print name, $1, $2, $3}' > $NAME.collapsedRegion.summary
	cat $NAME.collapsedRegion.summary | awk 'OFS="," {print $1, $2, $4}' > $NAME.summary.csv
	rm $NAME.trueLength
	rm $NAME.snpSum
#	rm $NAME.lengthEstimate.tmp
done

cat at*.summary.csv > summaryCollapsedRegions.csv
