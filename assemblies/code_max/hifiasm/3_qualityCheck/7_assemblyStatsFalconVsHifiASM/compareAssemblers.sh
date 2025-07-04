#!/bin/bash

#FALCON=`cat falcon.report.csv`
#HIFIASM=`cat hifiasm.report.csv`

cat falcon.report.csv | awk -F';' '{print $1, $15, "falcon"}' > largestContigComparison.4R.tmp
cat hifiasm.report.csv | awk -F';' '{print $1, $15, "hifiasm"}' >> largestContigComparison.4R.tmp

cat falcon.report.csv | awk -F';' '{print $1, $16, "falcon"}' > totalLengthComparison.4R.tmp
cat hifiasm.report.csv | awk -F';' '{print $1, $16, "hifiasm"}' >> totalLengthComparison.4R.tmp

cat falcon.report.csv | awk -F';' '{print $1, $20, "falcon"}' > contigN50Comparison.4R.tmp
cat hifiasm.report.csv | awk -F';' '{print $1, $20, "hifiasm"}' >> contigN50Comparison.4R.tmp

cat falcon.report.csv | awk -F';' '{print $1, $21, "falcon"}' > contigNG50Comparison.4R.tmp
cat hifiasm.report.csv | awk -F';' '{print $1, $21, "hifiasm"}' >> contigNG50Comparison.4R.tmp

cat falcon.report.csv | awk -F';' '{print $1, $25, "falcon"}' > contigLG50Comparison.4R.tmp
cat hifiasm.report.csv | awk -F';' '{print $1, $25, "hifiasm"}' >> contigLG50Comparison.4R.tmp

cat falcon.report.csv | awk -F';' '{print $1, $2, "falcon"}' > nContigComparison.4R.tmp
cat hifiasm.report.csv | awk -F';' '{print $1, $2, "hifiasm"}' >> nContigComparison.4R.tmp

sed -i -e 's/at/AT/g' *Comparison.4R.tmp


for i in $(ls *Comparison.4R.tmp); do
	NAME=$(cat $i | head -n1 | awk '{print $2}')
	OUTNAME=$(echo $i | awk -F'.tmp' '{print $1}')
	echo $NAME
	echo "accession;"$NAME";tool" > $OUTNAME
	cat $i | awk '$1 ~/^AT/' >> $OUTNAME
	sed -i -e 's/ /;/g' $OUTNAME
	rm $i
done
