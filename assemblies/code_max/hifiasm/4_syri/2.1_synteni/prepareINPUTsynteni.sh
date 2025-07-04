#!/bin/bash

for i in $(ls at*.syri.out); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	grep "SYNAL" $i | cut -f 1-3,6-8,10 > $NAME.wga.syn.block.txt
done
