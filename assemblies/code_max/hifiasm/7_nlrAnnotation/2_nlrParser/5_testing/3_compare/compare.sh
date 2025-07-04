#!/bin/bash

for i in $(ls at*.nlr.old.txt); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	diff $i $NAME.nlr.new.txt
done
