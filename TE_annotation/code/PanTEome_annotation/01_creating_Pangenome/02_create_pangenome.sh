#!/usr/bin/env bash


mkdir -p TE_annotation/input/genomes/
cd TE_annotation/input/genomes/

# Final assemblies are stored in:
path_genomes="path/to/genomes/"

# Add accession information to th fasta headers of each assembly and short its name.

for genome in $( ls ${path_genomes}at*.bionano.final_mod.fasta) ; do
        name=$(basename $genome .scaffolds.bionano.final_mod.fasta) ;
        sed "s/^>/>${name}_/;s/ptg0.*0/ptg/"  ${genome} > ./${name}.fasta
done

# In this separated instances we are going to call EDTA raw modules.
# Concatenate the pangenome for the later EDTA analyses  :
cat *fasta  > ../pangenome.fasta

# Preapre folders for raw EDTA:
mkdir -p TE_annotation/output/EDTA/ALL_genomes_EDTA_raw/
ln -s TE_annotation/input/pangenome.fasta TE_annotation/output/EDTA/

# Add symlinksto the folder
for genome in TE_annotation/input/genomes/at*fasta ; do
  ln -s $genome TE_annotation/output/EDTA/ALL_genomes_EDTA_raw/ ;
done
