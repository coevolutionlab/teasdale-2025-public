#!/bin/bash

for i in $(ls at*hints); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '$1 ~/^Chr/' | sed 's/ /\t/g' > $NAME.chrOnly.hints
done
