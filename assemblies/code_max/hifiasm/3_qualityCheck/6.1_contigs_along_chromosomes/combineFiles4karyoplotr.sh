#!/bin/bash

for i in $(ls at*.chrLength); do
	NAME=$(echo $i | awk -F'.' '{print $1}' | sed 's/at/AT/g')
	cat $i | awk -v var=$NAME '{print var, $1, $2, $3}' > $NAME.chrLength.tmp
done

for line in $(cat chr.names); do
	grep $line AT*.chrLength.tmp | awk -F':' '{print $2}' | awk '{print $1, $3}' > $line.summary
done

for file in $(ls at*.centromere.4R); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	cat $file | awk -v var=$NAME '{print var, $1, $2, $3, $4, $5}' > $file.tmp
done

for file in $(ls at*.centromere.4R.tmp); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	for line in $(cat chr.names); do
		grep $line $file > $NAME.$line.tmp
	done
done

for line in $(cat chr.names); do
	grep $line at*.$line.tmp | awk -F':' '{print $2}' | awk '{print $1, $3, $4, $5, $6}' | sed 's/ /\t/g' | sed 's/at/AT/g'  > $line.centromere.summary.4R
	sed -i -e '1i chr\tstart\tend\tname\tgieStain' $line.centromere.summary.4R
done
