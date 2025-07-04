#!/bin/bash

for i in $(ls at*.jf); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	jellyfish histo -t 20 $i > $NAME.reads.histo &
done
