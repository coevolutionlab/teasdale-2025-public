#!/bin/bash

source activate ragtag

#QSUB=
$RAGTAG=

for i in $(ls at*.p_ctg.noContamination.hifiasm.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	mkdir $NAME\_ragtagResults
	cd $NAME\_ragagResults
	ragtag.py correct -f 2000 -q 60 --remove-small -t 12 -R $NAME.*CCS*.fastq* -T corr -o $NAME\_ragtagResults at9852.bionanoHybridScaffold.noCorrection.repeatModeler_tantan.fasta $i &
done
