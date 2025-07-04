#!/bin/bash

source activate ragtag
RAGTAG="/ebio/abt6/mcollenberg/miniconda3/envs/ragtag/bin/ragtag.py"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"

for i in $(ls at*.hifiASM.p_ctg.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_ragtagResults
	cd $NAME\_ragtagResults
	$QSUB 20 2 $RAGTAG scaffold -f 2000 -t 20 -q 60 -o ./ ../at9852.bionanoHybridScaffold.noCorrection.repeatModeler_tantan.fasta ../$i &
	cd ../
done
