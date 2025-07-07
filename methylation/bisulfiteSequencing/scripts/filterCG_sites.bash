#!/bin/bash

tab=$'\t'

for i in {0..1}
do
    gunzip ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CG_features.txt.gz
    gunzip ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.positions.txt.gz
    while read a b
    do
        grep -w "${a}${tab}${b}" ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.CG_features.txt 
    done < ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth${i}.positions.txt

done
