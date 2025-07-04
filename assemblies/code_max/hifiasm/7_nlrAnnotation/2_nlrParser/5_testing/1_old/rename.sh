#!/bin/bash

for i in $(ls at*.nlr.txt); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cp $i $NAME.nlr.old.txt
done
