#!/bin/bash 

rm length.translocation.txt
rm length.inversion.txt
rm length.duplication.txt

rm length.translocation.ref.txt
rm length.inversion.ref.txt
rm length.duplication.ref.txt

for i in $(ls at*.syri.out); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk -v var="$NAME" '$11 == "TRANS" {print var, $8-$7}' > length.translocation.txt
	cat $i | awk -v var="$NAME" '$11 == "INV" {print var, $8-$7}' > length.inversion.txt
	cat $i | awk -v var="$NAME" '$11 == "DUP" {print var, $8-$7}' > length.duplication.txt
	cat $i | awk -v var="$NAME" '$11 == "TRANS" {print var, $3-$2}' > length.translocation.ref.txt
        cat $i | awk -v var="$NAME" '$11 == "INV" {print var, $3-$2}' > length.inversion.ref.txt
        cat $i | awk -v var="$NAME" '$11 == "DUP" {print var, $3-$2}' > length.duplication.ref.txt

done

for i in $(ls length.*.txt); do
	NAME=$(echo $i | awk -F'.' '{print $2}')
	cat $i | awk -F' ' '{print $2}' | sort -h >> length.$NAME.4R
done

for i in $(ls length.*.ref.txt); do
        NAME=$(echo $i | awk -F'.' '{print $2}')
        cat $i | awk -F' ' '{print $2}' | sort -h >> length.$NAME.ref.4R
done
