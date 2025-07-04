#!/bin/bash

for i in $(ls at*scaffolds*bionano.hifiasm.final.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	seqtk comp $i | head -n5 | awk '{print $1, $2}' > $NAME.chrComp
	grep 'Chr1' $NAME.chrComp > $NAME.chr1.comp
	grep 'Chr2' $NAME.chrComp > $NAME.chr2.comp
	grep 'Chr3' $NAME.chrComp > $NAME.chr3.comp
	grep 'Chr4' $NAME.chrComp > $NAME.chr4.comp
	grep 'Chr5' $NAME.chrComp > $NAME.chr5.comp
	cat centromere.summary.final.4R | awk -v name="$NAME" -F';' '$1 ~ name {print $5}' > $NAME.chr1.cen
	cat centromere.summary.final.4R | awk -v name="$NAME" -F';' '$1 ~ name {print $6}' > $NAME.chr2.cen
	cat centromere.summary.final.4R | awk -v name="$NAME" -F';' '$1 ~ name {print $7}' > $NAME.chr3.cen
	cat centromere.summary.final.4R | awk -v name="$NAME" -F';' '$1 ~ name {print $8}' > $NAME.chr4.cen
	cat centromere.summary.final.4R | awk -v name="$NAME" -F';' '$1 ~ name {print $9}' > $NAME.chr5.cen
	paste $NAME.chr1.comp $NAME.chr1.cen > $NAME.summary
	paste $NAME.chr2.comp $NAME.chr2.cen >> $NAME.summary
	paste $NAME.chr3.comp $NAME.chr3.cen >> $NAME.summary
	paste $NAME.chr4.comp $NAME.chr4.cen >> $NAME.summary
	paste $NAME.chr5.comp $NAME.chr5.cen >> $NAME.summary
	echo $NAME "done"
	cat $NAME.summary | awk '{print $1, $2, $3, ($2-$3)}' > $NAME.noCen
	rm $NAME.chr*.comp
	rm $NAME.chr*.cen
done
