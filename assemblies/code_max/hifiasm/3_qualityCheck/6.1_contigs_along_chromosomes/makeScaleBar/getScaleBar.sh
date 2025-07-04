#!/bin/bash

for i in $(ls Chr*.summary); do 
	NAME=$(echo $i | awk -F'.' '{print $1}')
 	L=$(cat $i | awk '{print $2}'| sort -h | tail -n1) 
	echo $NAME $L
done
