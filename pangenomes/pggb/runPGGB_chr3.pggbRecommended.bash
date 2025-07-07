#!/bin/bash
source ~/.bashrc
conda activate pggb
p=95
s=5000
n=17
k=47
G=700,900,1100
ref=at9852

out=chr3_cluster.p${p}.s${s}.n${n}.k${k}.G$(echo $G|tr ',' '-').$ref.pggbRecommended

mkdir -p ../$out

while read line
do 
    grep "chr3" \
    /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta.fai \
    |awk 'OFS="\t"{print $1, 0, $2}'  \
    > ../$out/$line.chr3.bed
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

while read line
do 
    bedtools getfasta -name \
    -fi /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta \
    -bed ../$out/${line}.chr3.bed \
    -fo ../$out/${line}.chr3.fasta
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

rm ../$out/chr3.fasta
cat ../$out/*.chr3.fasta \
> ../$out/chr3.fasta

sed -i "s/:://g" ../$out/chr3.fasta
bgzip -f ../$out/chr3.fasta
samtools faidx ../$out/chr3.fasta.gz

## for whole chr3
nice pggb \
-i ../$out/chr3.fasta.gz \
-p $p \
-s $s \
-n $n \
-t 12 \
-k $k \
-o ../$out \
-V 'at9852_1_chr3:#' \
-M \
-S \
-m \
-D /ptmp/gshirsekar/variation/tmp
