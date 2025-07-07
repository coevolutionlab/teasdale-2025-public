#!/bin/bash
source ~/.bashrc
conda activate pggb

mkdir -p ../chr3_cluster

while read line
do 
    grep "chr3" \
    /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta.fai \
    |awk 'OFS="\t"{print $1, 0, $2}'  \
    > ../chr3_cluster/$line.chr3.bed
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

while read line
do 
    bedtools getfasta -name \
    -fi /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta \
    -bed ../chr3_cluster/${line}.chr3.bed \
    -fo ../chr3_cluster/${line}.chr3.fasta
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

rm ../chr3_cluster/chr3.fasta
cat ../chr3_cluster/*.chr3.fasta \
> ../chr3_cluster/chr3.fasta

sed -i "s/:://g" ../chr3_cluster/chr3.fasta
bgzip -f ../chr3_cluster/chr3.fasta
samtools faidx ../chr3_cluster/chr3.fasta.gz

## for whole chr3
nice pggb \
-i ../chr3_cluster/chr3.fasta.gz \
-p 90 \
-s 5000 \
-n 18 \
-t 48 \
-k 47 \
-o ../chr3_cluster/out_p90_s5000 \
-V 'at9852_1_chr3:#' \
-M \
-S \
-m \
-D /ptmp/gshirsekar/variation/tmp
