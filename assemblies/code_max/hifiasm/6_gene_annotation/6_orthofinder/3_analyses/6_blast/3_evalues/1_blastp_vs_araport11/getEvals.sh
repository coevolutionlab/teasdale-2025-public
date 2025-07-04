#!/bin/bash


for i in $(ls at*.shared_genes.IDs); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo $NAME\_shared > $NAME.shared_genes.evals
	echo $NAME\_private > $NAME.private_genes.evals
	for line in $(cat $i); do
		grep $line $NAME\_blastp.out | awk '{print $11}' >> $NAME.shared_genes.evals &
	done
	for line in $(cat $NAME.private.IDs); do
		grep $line $NAME\_blastp.out | awk '{print $11}' >> $NAME.private_genes.evals
	done
done


for i in $(ls at*.shared_genes.IDs); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        echo $NAME\_shared > $NAME.shared_genes.evals
        echo $NAME\_private > $NAME.private_genes.evals
        for line in $(cat $i); do
                grep -m 1 $line $NAME\_blastp.out | awk '{print $11}' >> $NAME.shared_genes.bestHit.evals &
        done
        for line in $(cat $NAME.private.IDs); do
                grep -m 1 $line $NAME\_blastp.out | awk '{print $11}' >> $NAME.private_genes.bestHit.evals
        done
done

