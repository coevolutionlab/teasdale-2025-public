#!/usr/bin/env bash


# This script runs EDTA_raw  helitron module in  each gneome  with the names already modified separately to  try to speed up the proccess

conda activate /ebio/abt6_projects8/Tarvense_TE/code/conda_envs/EDTA_new

mkdir -p TE_annotation/output/EDTA/ALL_genomes_EDTA_raw/
cd TE_annotation/output/EDTA/ALL_genomes_EDTA_raw/

EDTA_raw="TE_annotation/code/EDTA/EDTA_raw.pl"

for genome in TE_annotation/output/EDTA/ALL_genomes_EDTA_raw/*fasta;
do
    perl ${EDTA_raw} --threads 16 --genome ${genome} --type helitron |&  tee $(basename ${genome} .fasta)_EDTA_raw_helitron.log ;
done
