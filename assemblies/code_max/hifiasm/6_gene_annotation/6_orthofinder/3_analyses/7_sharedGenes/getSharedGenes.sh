#!/bin/bash

rm shared.genes.tmp

for line in $(cat OG.list); do
	grep -w $line orthogroups.txt >> shared.genes.tmp &
done

cat shared.genes.tmp | tr ' ' '\n' > shared.genes.list

for line in $(cat acc.list); do
	grep $line shared.genes.list > $line.shared_genes.IDs
done
