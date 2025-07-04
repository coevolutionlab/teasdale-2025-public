#!/bin/bash


rm chr*Size.txt

for i in $(ls at*chrSize.txt); do
	NAME_OUT=$(echo $i | awk -F'.'  '{print $1}' | sed 's/at/AT/g')
	NAME_IN=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk -v name="$NAME_OUT" '$1 ~/^Chr1/ {print name, $2}' | sed 's/ /\t/g' >> chr1Size.txt
	cat $NAME_IN.edta_clean.filtered.gff | awk -v name="$NAME_OUT" '$1 !~/^Chr1/ {print "Chr"name, $4, $5, "gene"}' >> chr1.te.map
done
