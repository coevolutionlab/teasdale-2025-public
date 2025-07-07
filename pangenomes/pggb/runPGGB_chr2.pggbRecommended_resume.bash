#!/bin/bash -l
source ~/.bashrc
conda activate pggb
p=95
s=5000
n=17
k=47
G=700,900,1100
ref=at9852

out=chr2_cluster.p${p}.s${s}.n${n}.k${k}.G$(echo $G|tr ',' '-').$ref.pggbRecommended

## for whole chr2
nice pggb \
-i ../$out/chr2.fasta.gz \
-p $p \
-s $s \
-n $n \
-t 12 \
-k $k \
-o ../$out \
-V 'at9852_1_chr2:#' \
-M \
-S \
-m \
-r \
-D /ptmp/gshirsekar/variation/tmp
