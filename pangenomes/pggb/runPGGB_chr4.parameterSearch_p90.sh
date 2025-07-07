#!/bin/bash
source ~/.bashrc
conda activate pggb


for p in 90
do
for s in 1000 5000
do
for k in 31 47
do 


p=$p
s=$s
n=7
k=$k
G=700,900,1100
ref=at9852

out=chr4_cluster.p${p}.s${s}.n${n}.k${k}.G$(echo $G|tr ',' '-').$ref

mkdir -p ../$out

while read line
do 
    grep "chr4" \
    /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta.fai \
    |awk 'OFS="\t"{print $1, 0, $2}'  \
    > ../$out/$line.chr4.bed
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

while read line
do 
    bedtools getfasta -name \
    -fi /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta \
    -bed ../$out/${line}.chr4.bed \
    -fo ../$out/${line}.chr4.fasta
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

rm ../$out/chr4.fasta
cat ../$out/*.chr4.fasta \
> ../$out/chr4.fasta

sed -i "s/:://g" ../$out/chr4.fasta
bgzip -f ../$out/chr4.fasta
samtools faidx ../$out/chr4.fasta.gz

## for whole chr4
nice pggb \
-i ../$out/chr4.fasta.gz \
-p $p \
-s $s \
-n $n \
-t 24 \
-k $k \
-o ../$out \
-V 'at9852_1_chr4:#' \
-M \
-S \
-m \
-D /ptmp/gshirsekar/variation/tmp

done
done
done
