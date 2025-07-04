#!/bin/bash

for file in $(ls at*.mq.4R); do
	NAME=$(echo $file | awk -F'.' '{print $1}')
	cat $file | sed 's/\_RagTag\_RagTag//g' | awk -F';' '$4 == "chromosome"' > $NAME.chr.mq.4R
	cat $file | sed 's/\_RagTag\_RagTag//g' | awk -F';' '$4 != "chromosome"' > $NAME.unplaced.mq.4R
	echo $file
done
