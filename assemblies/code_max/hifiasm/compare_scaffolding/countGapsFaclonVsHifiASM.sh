#!/bin/bash

echo "accession" "falcon_bionano" "falcon_tair10" "hifiasm_bionano" "hifiasm_tair10"

for i in $(ls at*.bionano.falcon.scaffolds.agp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	B_F=$(cat $i | awk '$5 == "U"' | wc -l)
	T_F=$(cat $NAME.tair10.falcon.scaffolds.agp | awk '$5 == "U"' | wc -l)
	B_H=$(cat $NAME.bionano.hifiasm.scaffolds.agp | awk '$5 == "U"' | wc -l)
	T_H=$(cat $NAME.tair10.hifiasm.scaffolds.agp | awk '$5 == "U"' | wc -l)
	echo $NAME $B_F $B_H 
done
