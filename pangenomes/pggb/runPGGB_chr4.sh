#!/bin/bash
source ~/.bashrc
conda activate pggb

mkdir -p ../chr4_cluster

while read line
do 
    grep "chr4" \
    /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta.fai \
    |awk 'OFS="\t"{print $1, 0, $2}'  \
    > ../chr4_cluster/$line.chr4.bed
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

while read line
do 
    bedtools getfasta -name \
    -fi /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta \
    -bed ../chr4_cluster/${line}.chr4.bed \
    -fo ../chr4_cluster/${line}.chr4.fasta
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

rm ../chr4_cluster/chr4.fasta
cat ../chr4_cluster/*.chr4.fasta \
> ../chr4_cluster/chr4.fasta

sed -i "s/:://g" ../chr4_cluster/chr4.fasta
bgzip -f ../chr4_cluster/chr4.fasta
samtools faidx ../chr4_cluster/chr4.fasta.gz

## for whole chr4
nice pggb \
-i ../chr4_cluster/chr4.fasta.gz \
-p 90 \
-s 5000 \
-n 18 \
-t 48 \
-k 47 \
-o ../chr4_cluster/out_p90_s5000 \
-V 'at9852_1_chr4:#' \
-M \
-S \
-m \
-D /ptmp/gshirsekar/variation/tmp
