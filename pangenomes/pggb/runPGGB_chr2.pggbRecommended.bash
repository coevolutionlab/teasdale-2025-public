#!/bin/bash
source ~/.bashrc
conda activate pggb
p=95
s=5000
n=17
k=47
G=700,900,1100
ref=at9852

out=chr2_cluster.p${p}.s${s}.n${n}.k${k}.G$(echo $G|tr ',' '-').$ref.pggbRecommended

mkdir -p ../$out

while read line
do 
    grep "chr2" \
    /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta.fai \
    |awk 'OFS="\t"{print $1, 0, $2}'  \
    > ../$out/$line.chr2.bed
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

while read line
do 
    bedtools getfasta -name \
    -fi /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta \
    -bed ../$out/${line}.chr2.bed \
    -fo ../$out/${line}.chr2.fasta
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

rm ../$out/chr2.fasta
cat ../$out/*.chr2.fasta \
> ../$out/chr2.fasta

sed -i "s/:://g" ../$out/chr2.fasta
bgzip -f ../$out/chr2.fasta
samtools faidx ../$out/chr2.fasta.gz

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
-D /ptmp/gshirsekar/variation/tmp
