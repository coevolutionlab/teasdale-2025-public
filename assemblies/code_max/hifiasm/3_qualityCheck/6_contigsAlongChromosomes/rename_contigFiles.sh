#!/bin/bash

for i in $(ls at*.scaffolds.bionano.hifiasm.final.fasta.out.gff); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_out
	for file in $(ls chr*.contigs2); do
		FILE=$(echo $file)
		CHR=$(echo $file | awk -F'.' '{print $1}')
		cp $file $NAME\_$FILE
		sed -i -e 's/C/c/g' $NAME\_$FILE
		sed -i -e "s/$CHR/$NAME/g" $NAME\_$FILE
	done
	cd ../
done

