#!/bin/bash
cd /ebio/abt6_projects9/Methylome_variation_HPG1/pacBio/0_genomes/1_ccs_calling/at9883/1_q20 
t9883/g
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
ccs /ebio/seq/lra/runs/runs/64079/Diff_Lines20/r64079_20191106_131753/1_A01/m64079_191106_141522.subreads.bam /ebio/abt6_projects9/Methylome_variation_HPG1/pacBio/0_genomes/1_ccs_calling/at9883/1_q20/at9883.CCS.Q20.20.bam --chunk 20/20 -j 16 --min-rq 0.99
t9883/g
