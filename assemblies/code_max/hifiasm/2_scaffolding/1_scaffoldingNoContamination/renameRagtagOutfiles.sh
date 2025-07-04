#!/bin/bash

for i in $(ls at*.largeContigs100kb.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults_tair10
	cp ragtag.scaffold.agp $NAME.tair10.hifiasm.scaffolds.agp
	cd ../
done


for i in $(ls at*.largeContigs100kb.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_ragtagResults_bionano
        cp ragtag.scaffold.agp $NAME.bionano.hifiasm.scaffolds.agp
        cd ../
done
#!/bin/bash

for i in $(ls at*.largeContigs100kb.fasta); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	cd $NAME\_ragtagResults_tair10
	cp ragtag.scaffold.confidence.txt $NAME.tair10.hifiasm.confidence.txt
	cd ../
done


for i in $(ls at*.largeContigs100kb.fasta); do
        NAME=$(echo $i | awk -F'.' '{print $1}')
        cd $NAME\_ragtagResults_bionano
        cp ragtag.scaffold.confidence.txt $NAME.bionano.hifiasm.confidence.txt
        cd ../
done
