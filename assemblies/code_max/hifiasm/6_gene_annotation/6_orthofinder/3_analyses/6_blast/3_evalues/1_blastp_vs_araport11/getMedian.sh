#!/bin/bash

for i in $(ls at*.private_genes.evals); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	nums=$(cat $i); 
		list=(`for n in $nums; do printf "%015.06f\n" $n; done | sort -n`)
		echo min $NAME ${list[0]}
		echo max $NAME ${list[${#list[*]}-1]}
		echo median $NAME ${list[${#list[*]}/2]}
done

for i in $(ls at*.shared_genes.evals); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        nums=$(cat $i); 
                list=(`for n in $nums; do printf "%015.06f\n" $n; done | sort -n`)
                echo min $NAME ${list[0]}
                echo max $NAME ${list[${#list[*]}-1]}
                echo median $NAME ${list[${#list[*]}/2]}
done
