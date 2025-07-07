#!/bin/bash -l
source /mpcdf/soft/SLE_15/packages/x86_64/anaconda/3/2021.05/etc/profile.d/conda.sh
conda activate /u/gshirsekar/conda-envs/ccsmeth
accession=at6923

ref=../../../../assembly-and-annotation/output/01_assembly/03_inversion_fixed/${accession}.fasta

model=../../input/models/CG/attbigru2s.b21_epoch4.ckpt 

cut -f1 ${ref}.fai > ../../mappings/${accession}.contigs


ccsmeth call_freqb \
	--threads 5 \
	--input_bam ../../output/${accession}/CG/${accession}_mCG.modbam.bam \
	--ref ${ref} --contigs ../../mappings/${accession}.contigs \
  	--output ../../output/${accession}/freqfiles/${accession}.mCG.freqBED \
	--bed --sort --gzip --motifs CG --mapq 30
 


