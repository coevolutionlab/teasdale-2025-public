#!/bin/bash -l
source /mpcdf/soft/SLE_15/packages/x86_64/anaconda/3/2021.05/etc/profile.d/conda.sh
conda activate /u/gshirsekar/conda-envs/ccsmeth

echo -e "import watermark \nprint(watermark.watermark())" > loadwatermark.py

python loadwatermark.py > system.info

pip list > packages.info
accession=at9900

reads=../../../hifiWithKinetics/${accession}/${accession}.hifi_withKinetics.bam

ref=../../../../assembly-and-annotation/output/01_assembly/03_inversion_fixed/${accession}.fasta

output=../../mappings/${accession}.hifi_withKinetics_mapped_to_${accession}.bam

threads=12


nice ccsmeth align_hifi \
	--hifireads ${reads} \
	--ref ${ref} \
	--output ${output} \
	--threads ${threads}


mkdir -p ../../output/logfiles_${accession} 
mkdir -p ../../output/${accession}/CG/${accession}_CG

sbatch call_modifications.CG.raven.slurm 


