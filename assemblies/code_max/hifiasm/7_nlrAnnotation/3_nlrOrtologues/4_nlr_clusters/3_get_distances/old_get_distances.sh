#!/bin/bash

for i in $(ls at*.nlr.liftoff.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | grep 'NLR=' | awk '$3 == "gene" {print $1, $4, $5}' >> $NAME.tmp
	cat $NAME.tmp | awk '$1 ~/^Chr1/ {print $2, $3}' >> $NAME.chr1.tmp
	cat $NAME.chr1.tmp | awk '{print $1}' >> $NAME.chr1.start.tmp
	cat $NAME.chr1.tmp | awk '{print $2}' >> $NAME.chr1.end.tmp
	cat $NAME.chr1.start.tmp | sed -e '1d' >> $NAME.chr1.start.tmp
	cat $NAME.chr1.end.tmp | sed -e '$ d' >> $NAME.chr1.end.tmp
	cat $NAME.chr1.start.tmp $NAME.chr1.end.tmp >> $NAME.chr1.dist.tmp
	cat $NAME.chr1.dist.tmp | awk '{print $1-$2}' > $NAME.chr1.dist
	cat $NAME.tmp | awk '$1 ~/^Chr2/ {print $2, $3}' >> $NAME.chr2.tmp
	cat $NAME.chr2.tmp | awk '{print $1}' >> $NAME.chr2.start.tmp
	cat $NAME.chr2.tmp | awk '{print $2}' >> $NAME.chr2.end.tmp
	cat $NAME.chr2.start.tmp | sed -e '1d' >> $NAME.chr2.start.tmp
	cat $NAME.chr2.end.tmp | sed -e '$ d' >> $NAME.chr2.end.tmp
	cat $NAME.chr2.start.tmp $NAME.chr2.end.tmp >> $NAME.chr2.dist.tmp
	cat $NAME.chr2.dist.tmp | awk '{print $1-$2}' > $NAME.chr2.dist
	cat $NAME.tmp | awk '$1 ~/^Chr3/ {print $2, $3}' >> $NAME.chr3.tmp
	cat $NAME.chr3.tmp | awk '{print $1}' >> $NAME.chr3.start.tmp
	cat $NAME.chr3.tmp | awk '{print $2}' >> $NAME.chr3.end.tmp
	cat $NAME.chr3.start.tmp | sed -e '1d' >> $NAME.chr3.start.tmp
	cat $NAME.chr3.end.tmp | sed -e '$ d' >> $NAME.chr3.end.tmp
	cat $NAME.chr3.start.tmp $NAME.chr3.end.tmp >> $NAME.chr3.dist.tmp
	cat $NAME.chr3.dist.tmp | awk '{print $1-$2}' > $NAME.chr3.dist
	cat $NAME.tmp | awk '$1 ~/^Chr4/ {print $2, $3}' >> $NAME.chr4.tmp
	cat $NAME.chr4.tmp | awk '{print $1}' >> $NAME.chr4.start.tmp
	cat $NAME.chr4.tmp | awk '{print $2}' >> $NAME.chr4.end.tmp
	cat $NAME.chr4.start.tmp | sed -e '1d' >> $NAME.chr4.start.tmp
	cat $NAME.chr4.end.tmp | sed -e '$ d' >> $NAME.chr4.end.tmp
	cat $NAME.chr4.start.tmp $NAME.chr4.end.tmp >> $NAME.chr4.dist.tmp
	cat $NAME.chr4.dist.tmp | awk '{print $1-$2}' > $NAME.chr4.dist
	cat $NAME.tmp | awk '$1 ~/^Chr5/ {print $2, $3}' >> $NAME.chr5.tmp
	cat $NAME.chr5.tmp | awk '{print $1}' >> $NAME.chr5.start.tmp
	cat $NAME.chr5.tmp | awk '{print $2}' >> $NAME.chr5.end.tmp
	cat $NAME.chr5.start.tmp | sed -e '1d' >> $NAME.chr5.start.tmp
	cat $NAME.chr5.end.tmp | sed -e '$ d' >> $NAME.chr5.end.tmp
	cat $NAME.chr5.start.tmp $NAME.chr5.end.tmp >> $NAME.chr5.dist.tmp
	cat $NAME.chr5.dist.tmp | awk '{print $1-$2}' > $NAME.chr5.dist
	rm $NAME.tmp
	rm $NAME.*.tmp
	for file in $(ls $NAME.chr*.dist); do
		chr=$(echo $file | awk -F'.' '{print $2}')
		no=$(cat $file | awk '$1 <= 200000' | wc -l)
		echo $NAME $chr $no >> $NAME.cluster
	done
done
