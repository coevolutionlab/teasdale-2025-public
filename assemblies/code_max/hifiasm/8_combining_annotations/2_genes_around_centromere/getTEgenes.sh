#!/bin/bash

for line in $(cat TE.genes.list); do
	grep $line Orthogroups.txt >> test.txt
done
