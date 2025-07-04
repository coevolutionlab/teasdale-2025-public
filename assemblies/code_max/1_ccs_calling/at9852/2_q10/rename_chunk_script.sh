source activate ccs
#!/bin/bash

for i in $(ls at*.Q20.chunk*.sh); do
	ACCESSION=$(echo $i | awk -F'.' '{print $1}')
	CHUNK=$(echo $i | awk -F'.' '{print $3}')
	mv $i $ACCESSION.Q10.$CHUNK.sh
done
