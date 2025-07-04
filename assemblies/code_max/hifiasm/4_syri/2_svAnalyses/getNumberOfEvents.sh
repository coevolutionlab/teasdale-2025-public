#!/bin/bash

for i in $(ls at*.INV.length); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	TYPE=$(echo $i | awk -F'.' '{print $2}')
	NO=$(cat $i | awk 'NF==1' | wc -l)
	cat $i | awk '$1 !~/^at/' > $i.tmp
	MEDIAN=$(cat $i.tmp | jq -s 'sort|if length%2==1 then.[length/2|floor]else[.[length/2-1,length/2]]|add/2 end' | sort -n|awk '{a[NR]=$0}END{print(NR%2==1)?a[int(NR/2)+1]:(a[NR/2]+a[NR/2+1])/2}')
	echo $NAME $TYPE $NO $MEDIAN
	echo $NAME $NO $MEDIAN >> $TYPE.number.4R
	rm $i.tmp
done


for i in $(ls at*.TRANS.length); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        TYPE=$(echo $i | awk -F'.' '{print $2}')
        NO=$(cat $i | awk 'NF==1' | wc -l)
	cat $i | awk '$1 !~/^at/' > $i.tmp
	MEDIAN=$(cat $i.tmp | jq -s 'sort|if length%2==1 then.[length/2|floor]else[.[length/2-1,length/2]]|add/2 end' | sort -n|awk '{a[NR]=$0}END{print(NR%2==1)?a[int(NR/2)+1]:(a[NR/2]+a[NR/2+1])/2}')
        echo $NAME $TYPE $NO $MEDIAN
        echo $NAME $NO $MEDIAN >> $TYPE.number.4R
	rm $i.tmp
done

for i in $(ls at*.DUP.length); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        TYPE=$(echo $i | awk -F'.' '{print $2}')
        NO=$(cat $i | awk 'NF==1' | wc -l)
	cat $i | awk '$1 !~/^at/' > $i.tmp
	MEDIAN=$(cat $i.tmp | jq -s 'sort|if length%2==1 then.[length/2|floor]else[.[length/2-1,length/2]]|add/2 end' | sort -n|awk '{a[NR]=$0}END{print(NR%2==1)?a[int(NR/2)+1]:(a[NR/2]+a[NR/2+1])/2}')
        echo $NAME $TYPE $NO $MEDIAN
        echo $NAME $NO $MEDIAN >> $TYPE.number.4R
	rm $i.tmp
done
