#!/bin/bash

source activate  /ebio/abt6_projects8/Tarvense_TE/code/conda_envs/EDTA_new/

cd /tmp/global3/kmurray/difflines/adri-tips/EDTA_18G/
EDTA="/ebio/abt6_projects8/Tarvense_TE/code/EDTA/EDTA.pl"
TAIR10_TE_lib="/ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/TElib/TAIR10_TEs/TAIR10lib_EDTA/TAIR10_mod_TE.fa"
cds="/ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/EDTA_TAIR10lib/Araport11_genes.201606.cds.fasta"
genome="/ebio/abt6_projects7/diffLines_20/data/Adrian_TIPs/data/genomes/at6929/at6929.scaffolds.bionano.final_mod.fasta"

perl ${EDTA} --threads 16 --genome ${genome} \
--cds ${cds} \
--sensitive 1 \
--anno 1   \
--evaluate 1 \
--curatedlib  ${TAIR10_TE_lib}  |&  tee $(basename ${genome} .fasta)_EDTA_rerun.log


