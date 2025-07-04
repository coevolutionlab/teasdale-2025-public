#!/bin/bash

for line in $(cat genes.list.ids); do
	grep $line Orthogroups.tsv
done
