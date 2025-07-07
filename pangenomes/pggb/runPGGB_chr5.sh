#!/bin/bash
source ~/.bashrc
conda activate pggb

mkdir -p ../chr5_cluster

while read line
do 
    grep "chr5" \
    /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta.fai \
    |awk 'OFS="\t"{print $1, 0, $2}'  \
    > ../chr5_cluster/$line.chr5.bed
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

while read line
do 
    bedtools getfasta -name \
    -fi /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta \
    -bed ../chr5_cluster/${line}.chr5.bed \
    -fo ../chr5_cluster/${line}.chr5.fasta
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

rm ../chr5_cluster/chr5.fasta
cat ../chr5_cluster/*.chr5.fasta \
> ../chr5_cluster/chr5.fasta

sed -i "s/:://g" ../chr5_cluster/chr5.fasta
bgzip -f ../chr5_cluster/chr5.fasta
samtools faidx ../chr5_cluster/chr5.fasta.gz

## for whole chr5
nice pggb \
-i ../chr5_cluster/chr5.fasta.gz \
-p 90 \
-s 5000 \
-n 18 \
-t 12 \
-k 47 \
-o ../chr5_cluster/out_p90_s5000 \
-V 'at9852_1_chr5:#' \
-M \
-S \
-m \
-D /ptmp/gshirsekar/variation/tmp
