#!/bin/bash

for i in $(ls at*.samtools.depth); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	COVERAGE=$(cat $i | awk -F'= ' '{print $2}')
	cat $NAME.snp.summary.final | awk -v coverage="$COVERAGE" 'OFS="\t" {print $1, $2, $3, $4, $5, (($4/coverage)*5)}' > $NAME.lengthEstimate.tmp
	cat $NAME.lengthEstimate.tmp | awk '{sum+=$6} END {print sum}' > $NAME.trueLength
	cat $NAME.lengthEstimate.tmp | awk '{sum+=$5} END {print sum}' > $NAME.snpSum
	paste $NAME.trueLength $NAME.snpSum | awk -v name=$NAME 'OFS="\t" {print name, $1, $2}' > $NAME.collapsedRegion.summary
	rm $NAME.trueLength
	rm $NAME.snpSum
	rm $NAME.lengthEstimate.tmp
done
