#!/bin/bash

for i in $(ls *.list); do
	NAME=$(echo $i | awk -F'.' '{print $2}')
	NO=$(cat $i | wc -l)
	if [ $NO -lt 19 ]
	then
		echo $NAME $NO
	fi
done


for i in $(ls *.list); do
        NAME=$(echo $i | awk -F'.' '{print $2}')
        NO=$(cat $i | wc -l)
        if [ $NO -eq 19 ]
        then
                echo $NAME $NO
        fi
done
