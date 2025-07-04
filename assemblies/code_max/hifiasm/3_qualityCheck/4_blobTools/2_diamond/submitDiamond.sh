#!/bin/bash


QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"
DIAMOND="/ebio/abt6/mcollenberg/miniconda3/envs/blob/bin/diamond"


for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_diamondResults
	cd $NAME\_diamondResults
	source activate blob
	$QSUB 64 15 $DIAMOND blastx --top 10 -b 10 -c 1 -d /ebio/abt6_projects9/phyllosphere_metagenome_assembly/data/DB/NR_diamond_2020_Feb/nr -q ../$i -o $NAME.hifiasm.primaryContigs.m8 --sensitive -p 64 -f 102
	cd ../
done




