#!/bin/bash


#for i in $(ls *sam); do
#	NAME=$(echo $i | awk -F".sam" '{print $1}')
#	mkdir $NAME
#	cd $NAME
#	cufflinks --num-threads 12 --output-dir ./ ../$i &
#	cd ../
#done


for i in $(ls hybrid*_at*Aligned.sortedByCoord.out.bam); do
	NAME=$(echo $i | awk -F"A" '{print $1}' | awk -F'_' '{print $2}')
	mkdir $NAME
        cd $NAME
        cufflinks --num-threads 12 --output-dir ./ ../$i &
        cd ../
done
