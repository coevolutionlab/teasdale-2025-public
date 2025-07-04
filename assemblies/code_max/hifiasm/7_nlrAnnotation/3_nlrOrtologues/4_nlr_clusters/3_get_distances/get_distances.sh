#!/bin/bash

for i in $(ls at*.nlr.positions.bed); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	for chr in $(cat $i | awk -F'_' '$1 !~/^ptg/ {print $1}' | sort | uniq); do
		grep $chr $NAME.nlr.positions.bed > $NAME.$chr.nlr.positions.tmp
		cat $NAME.$chr.nlr.positions.tmp | awk -F' ' '{print $2}' | sed -e '1 d' > $NAME.$chr.start
		cat $NAME.$chr.nlr.positions.tmp | awk -F' ' '{print $3}' | sed -e '$ d' > $NAME.$chr.end
		paste $NAME.$chr.start $NAME.$chr.end | awk '{print $1-$2}'  > $NAME.$chr.dist
	done
	cat $NAME.Chr*.dist > $NAME.nlr.distances
	echo $NAME
	rm $NAME.Chr*.dist
	rm $NAME.Chr*.nlr.positions.tmp
	rm $NAME.Chr*.start $NAME.Chr*.end
done


#cat $NAME.chr5.start.tmp | sed -e '1d' >> $NAME.chr5.start.tmp
#	cat $NAME.chr5.end.tmp | sed -e '$ d' >> $NAME.chr5.end.tmp	
