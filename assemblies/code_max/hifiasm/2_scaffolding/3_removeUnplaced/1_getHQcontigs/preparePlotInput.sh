#!/bin/bash


#!/bin/bash

cat mq.tsv | awk '{print $1}' | sort | uniq | awk '$1 ~/^at/' > names.txt

for line in $(cat names.txt); do
	NAME=$(echo $line)
	grep "$NAME" mq.tsv | awk 'OFS=";" {print $2, $3, $4, $5}' > $NAME.mq.4R.tmp
	cat $NAME.mq.4R.tmp | awk -F';' '$2 ~/^Chr/ {print $1, $2, $3, "chromosome", $4}' > $NAME.mq.4R
	cat $NAME.mq.4R.tmp | awk -F';' '$2 ~/^ptg/ {print $1, $2, $3, "unplacedContig", $4}' >> $NAME.mq.4R
	sed -i -e 's/ /;/g' $NAME.mq.4R
	echo "processed sample" $NAME
done
