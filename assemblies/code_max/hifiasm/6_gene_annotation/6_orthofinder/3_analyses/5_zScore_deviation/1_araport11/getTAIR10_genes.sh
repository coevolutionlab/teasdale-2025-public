#!/bin/bash

for i in $(ls tair10_z_score_above4.list); do
	NAME=$(echo $i | awk -F'_' '{print $4}')
	echo $NAME > geneIDs.$NAME.list.tmp
	for line in $(cat $i); do
		grep -w $line Orthogroups.txt | sed 's/ /\n/g' | awk '$1 ~/^Araport/ {print}' | awk -F'_' '{print $2}' >> geneIDs.$NAME.list.tmp
	done
	cat geneIDs.$NAME.list.tmp | awk -F'.' '{print $1}' | sort | uniq > geneIDs.$NAME.list
	rm geneIDs.$NAME.list.tmp
done


for i in $(ls tair10_z_score_below-4.list); do
        NAME=$(echo $i | awk -F'_' '{print $4}')
        echo $NAME > geneIDs.$NAME.list.tmp
        for line in $(cat $i); do
                grep -w $line Orthogroups.txt | sed 's/ /\n/g' | awk '$1 ~/^Araport/ {print}' | awk -F'_' '{print $2}' >> geneIDs.$NAME.list.tmp
        done
        cat geneIDs.$NAME.list.tmp | awk -F'.' '{print $1}' | sort | uniq > geneIDs.$NAME.list
        rm geneIDs.$NAME.list.tmp
done

