#!/bin/bash

for i in $(ls at*Q20*fastq*); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	jellyfish count -t 15 -C -m 21 -s 1000000000 $i -o $NAME.reads.jf &
done

