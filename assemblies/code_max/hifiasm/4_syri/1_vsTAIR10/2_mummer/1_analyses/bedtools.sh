#!/bin/bash

#bedtools multiinter -i *.wga.syn.block.txt  -names at6137 at6923 at6929 at7143 at8285 at9104 at9336 at9503 at9578 at9744 at9762 at9806 at9830 at9847 at9852 at9879 at9883 at9900 > Col.syn.txt
#awk '{if ($4==18) print}' Col.syn.txt >Col.syn.all.txt  ##change the "7" according to the number of your genomes

#for k in {at6137,at6923,at6929,at7143,at8285,at9104,at9336,at9503,at9578,at9744,at9762,at9806,at9830,at9847,at9852,at9879,at9883,at9900}; do  
#	echo $k
 #   for j in {1..5}; do show-aligns -r $k/out_m_i90_l100.delta Chr$j Chr$j > $k/out_m_i90_l100.chr$j.aligns ; done ;
#done

for k in {at6137,at6923,at6929,at7143,at8285,at9104,at9336,at9503,at9578,at9744,at9762,at9806,at9830,at9847,at9852,at9879,at9883,at9900};  do cat $k/out_m_i90_l100.chr*.aligns >$k/$k.aligns ;done &


#perl get.all.syn.coord.pl ./Col.syn.all.txt ../../results/pairwiseAssV2/Col/ ./Col.syn.all.coords.txt &  ##maybe, please modify the line 86 and 98 accordingly if you have different number of genomes

