#!/bin/bash
cd /ebio/abt6_projects9/Methylome_variation_HPG1/pacBio/0_genomes/1_ccs_calling/at9900/2_q30 
#qsub RAD16_map.sh is the execution command
#  Import environment
#$ -V
#  Reserve 1 CPUs for this job
#$ -pe parallel 16
#
#  Request 240G of RAM
#$ -l h_vmem=24G
#
#  The name shown in the qstat output and in the output file(s). The
#  default is to use the script name.
#$ -N at9883_chunk1
#
#  The path used for standard error stream of the job
#$ -e /ebio/abt6_projects9/Methylome_variation_HPG1/pacBio/passes10/chunk1.log
#
#  Use /bin/bash to execute this scripti
#$ -S /bin/bash
#
#
#  Send email when the job begins, ends, aborts, or is suspended
#$ -m beas
#
ccs /ebio/seq/lra/runs/runs/64079/Diff_Lines20/r64079_20191106_131753/2_B01/m64079_191107_202816.subreads.bam /ebio/abt6_projects9/Methylome_variation_HPG1/pacBio/0_genomes/1_ccs_calling/at9900/2_q30/at9900.CCS.Q30.2.bam --chunk 2/20 -j 16 --min-rq 0.999
