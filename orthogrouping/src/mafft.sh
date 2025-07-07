#!/bin/bash
#set -xe

for sample in $(cat samples2.txt)
do  
   #mafft --auto  ${sample}.fa > ${sample}_broad_aa_mafft.fa
   #iqtree -s ${sample}_broad_aa_mafft.fa -m JTT -bb 1000
   iqtree2 -s ${sample}_broad_aa_mafft.fa --model-joint NONREV -B 1000 -T AUTO --prefix ${sample}_nonrev_aa --redo
done
