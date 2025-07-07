#!/bin/bash -l
source /mpcdf/soft/SLE_15/packages/x86_64/anaconda/3/2021.05/etc/profile.d/conda.sh
conda activate /u/gshirsekar/conda-envs/ccsmeth
accession=at6137

ref=../../../../assembly-and-annotation/output/01_assembly/03_inversion_fixed/${accession}.fasta

model=../../input/models/CG/attbigru2s.b21_epoch4.ckpt 

cut -f1 ${ref}.fai > ../../mappings/${accession}.contigs


ccsmeth call_freqt \
	--threads 5 \
	--input_path ../../output/${accession}/CG/${accession}_mCG.per_readsite.tsv \
	--ref ${ref} --contigs ../../mappings/${accession}.contigs \
  	-o ../../output/${accession}/freqfiles/${accession}.mCG.freqBED \
	--bed --sort --gzip --motifs CG 
 


