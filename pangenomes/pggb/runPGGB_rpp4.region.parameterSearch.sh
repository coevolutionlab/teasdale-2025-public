#!/bin/bash
source ~/.bashrc
conda activate pggb


for p in 70 80 90 
do
for s in 500 1000 1500 5000
do
for k in 21 31 47
do 


p=$p
s=$s
n=18
k=$k
G=700,900,1100
ref=at9852

out=rpp4region.p${p}.s${s}.n${n}.k${k}.G$(echo $G|tr ',' '-').$ref

mkdir -p ../$out



## for whole chr4
nice pggb \
-i /ptmp/gshirsekar/variation/test/chr4_cluster.p95.s5000.n7.k47.G700-900-1100.at9852/allAccessions.at9900.rpp4.region.fasta.gz \
-p $p \
-s $s \
-n $n \
-t 8 \
-k $k \
-o ../$out \
-V 'at9852_1_chr4:#' \
-M \
-S \
-m \
-r \
-D /ptmp/gshirsekar/variation/tmp

done
done
done
