#!/bin/bash

echo "missing" > missing.list
echo "fragmented" > fragmented.list
echo "duplicated" > duplicated.list

rm missing.odb
rm duplicated.odb
rm fragmented.odb

for i in $(ls at*full_table.tsv); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 !~/^#/ && $2 == "Missing" {print $1}' >> missing.list
	cat $i | awk '$1 !~/^#/ && $2 == "Fragmented" {print $1}' >> fragmented.list
	cat $i | awk '$1 !~/^#/ && $2 == "Duplicated" {print $1}' | sort | uniq >> duplicated.list
done



for line1 in $(cat missing.list | sort | uniq); do
	grep -w $line1 links_to_ODB10.txt >> missing.odb
done

for line2 in $(cat fragmented.list); do
	grep -w $line2 links_to_ODB10.txt >> fragmented.odb
done

for line3 in $(cat duplicated.list); do
	grep -w $line3 links_to_ODB10.txt >> duplicated.odb
done

