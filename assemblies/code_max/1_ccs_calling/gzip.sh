#!/bin/bash

for i in $(find . -name "*.fasta"); do
	gzip --fast $i &
done
