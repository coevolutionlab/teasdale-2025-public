#!/bin/bash

source activate ragtag2
RAGTAG="/ebio/abt6/mcollenberg/miniconda3/envs/ragtag2/bin/ragtag.py"
QSUB="/ebio/abt6/mcollenberg/0_deg_analyses_scripts/1_DEG_analyses_wrapper/qsub.perl"

#for i in $(ls at*.largeContigs100kb.fasta); do
#	NAME=$(echo $i | awk -F'.' '{print $1}')
#	mkdir $NAME\_ragtagResults_tair10
#	cd $NAME\_ragtagResults_tair10
#	$QSUB 20 2 $RAGTAG scaffold -f 30000 -t 20 -q 60 --remove-small -i 0.5 -o ./ ../TAIR10.hard_masked.fa ../$i &
#	cd ../
#done


#for i in $(ls at*.largeContigs100kb.fasta); do
 #       NAME=$(echo $i | awk -F'.' '{print $1}')
 #       mkdir $NAME\_ragtagResults_bionano
 #       cd $NAME\_ragtagResults_bionano
#        $QSUB 20 2 $RAGTAG scaffold -f 30000 -t 20 -q 60 --remove-small -i 0.5 -o ./ ../at9852.bionanoHybridScaffold.noCorrection.repeatModeler_tantan.fasta ../$i &
#        cd ../
#done



for i in $(ls at*.largeContigs100kb.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        mkdir $NAME\_ragtagResults_tair10
        cd $NAME\_ragtagResults_tair10
        $RAGTAG scaffold -f 30000 -t 10 -q 60 --remove-small -i 0.5 -o ./ ../TAIR10.hard_masked.fa ../$i &
        cd ../
done


for i in $(ls at*.largeContigs100kb.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        mkdir $NAME\_ragtagResults_bionano
        cd $NAME\_ragtagResults_bionano
        $RAGTAG scaffold -f 30000 -t 10 -q 60 --remove-small -i 0.5 -o ./ ../at9852.bionanoHybridScaffold.noCorrection.repeatModeler_tantan.fasta ../$i &
        cd ../
done

