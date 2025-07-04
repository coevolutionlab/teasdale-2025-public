#!/bin/bash

for i in $(ls at*fastq.gz); do
	gunzip $i &
done
