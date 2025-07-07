#!/usr/bin/env bash

source activate  /ebio/abt6_projects8/Tarvense_TE/code/conda_envs/EDTA_new/

cd /tmp/global3/kmurray/difflines/adri-tips/EDTA_18G/
EDTA="/ebio/abt6_projects8/Tarvense_TE/code/EDTA/EDTA.pl"
TAIR10_TE_lib="/ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/TElib/TElib/TAIR10_TEs/TAIR10lib_EDTA/TAIR10_mod_TE.fa"
cds="/ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/EDTA_TAIR10lib/Araport11_genes.201606.cds.fasta"

for genome in $( ls /ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/genomes/*/at*.bionano.final_mod.fasta) ;
do
nice perl ${EDTA} --threads 25 \
--genome ${genome} \
--cds ${cds} \
--sensitive 1 \
--anno 1   \
--evaluate 1 \
--curatedlib  /ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/TElib/TElib/TAIR10_TEs/TAIR10lib_EDTA/TAIR10_mod_TE.fa  2>  $(basename ${genome} .fasta)_EDTA.log
done


