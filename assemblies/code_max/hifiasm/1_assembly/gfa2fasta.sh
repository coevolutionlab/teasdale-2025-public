#!/bin/bash

for i in $(ls at*.hifiasm.bp.p_ctg.gfa); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cat $i | awk '/^S/{print ">"$2"\n"$3}' >> $NAME.hifiASM.p_ctg.fasta 
done
