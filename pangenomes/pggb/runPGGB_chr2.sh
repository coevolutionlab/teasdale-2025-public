#!/bin/bash
source ~/.bashrc
conda activate pggb

mkdir -p ../chr2_cluster

while read line
do 
    grep "chr2" \
    /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta.fai \
    |awk 'OFS="\t"{print $1, 0, $2}'  \
    > ../chr2_cluster/$line.chr2.bed
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

while read line
do 
    bedtools getfasta -name \
    -fi /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/${line}.scaffolds-v2.3.fasta \
    -bed ../chr2_cluster/${line}.chr2.bed \
    -fo ../chr2_cluster/${line}.chr2.fasta
done < /ptmp/gshirsekar/dl20-annex-unfucked/graffite/input/accessions.txt

rm ../chr2_cluster/chr2.fasta
cat ../chr2_cluster/*.chr2.fasta \
> ../chr2_cluster/chr2.fasta

sed -i "s/:://g" ../chr2_cluster/chr2.fasta
bgzip -f ../chr2_cluster/chr2.fasta
samtools faidx ../chr2_cluster/chr2.fasta.gz

## for whole chr2
nice pggb \
-i ../chr2_cluster/chr2.fasta.gz \
-p 90 \
-s 5000 \
-n 18 \
-t 48 \
-k 47 \
-o ../chr2_cluster/out_p90_s5000 \
-V 'at9852_1_chr2:#' \
-M \
-S \
-m \
-D /ptmp/gshirsekar/variation/tmp
