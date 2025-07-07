#!/bin/bash -l
# Standard output and error:
#SBATCH -o ./chunk5_tjob.out.%j
#SBATCH -e ./chunk5_tjob.err.%j
# Initial working directory:
#SBATCH -D ./
# Job Name:
#SBATCH -J chunk5
#
# Number of nodes and MPI tasks per node:
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
# Enable Hyperthreading:
#SBATCH --ntasks-per-core=2
# for OpenMP:
#SBATCH --cpus-per-task=80
#
# Request 180 GB of main memory per node in units of MB:
#SBATCH --mem=185000
#
#
#SBATCH --mail-type=none
#SBATCH --mail-user=gshirsekar@tuebingen.mpg.de
#
# Wall clock limit:
#SBATCH --time=24:00:00

# Load compiler and MPI modules with explicit version specifications,
# consistently with the versions used to build the executable.
module purge
module load intel/19.1.3 impi/2019.9

source ~/.bashrc
conda activate pggb
p=95
s=5000
n=17
k=47
G=700,900,1100
ref=at9852

out=chr5_cluster.p${p}.s${s}.n${n}.k${k}.G$(echo $G|tr ',' '-').$ref.pggbRecommended

## for whole chr5
pggb \
-i ../$out/chr5.fasta.gz \
-p $p \
-s $s \
-n $n \
-t 4 \
-T 4 \
-k $k \
-o ../$out \
-V 'at9852_1_chr5:#' \
-M \
-S \
-m \
-r \
-D /ptmp/gshirsekar/variation/tmp
