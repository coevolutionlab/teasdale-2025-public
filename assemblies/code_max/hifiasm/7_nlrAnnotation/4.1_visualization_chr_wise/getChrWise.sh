#!/bin/bash









for line in $(cat chr.names); do
	NAME=$(echo $line | awk -F'.' '{print $1}')
	grep $line at*.chrSize.txt | sed 's/\t/;/g' | sed 's/\./;/g' | awk -F';' '{print $1, $4}' | sed 's/at/AT/g'| sed 's/ /\t/g' > $NAME.sizeSummary.4R
	grep $line at*.nlr.map | sed 's/\t/;/g' | sed 's/\./;/g' | awk -F';' '{print $1, $4, $5, $6}' | sed 's/at/AT/g' | sed 's/ /\t/g'  > $NAME.nlrMapSummary.4R
done

sed -i '1ichrom\tstart\tend\tfeature' Chr*.nlrMapSummary.4R

