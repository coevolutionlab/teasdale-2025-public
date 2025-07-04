#!/bin/bash

for i in $(ls at*.*.agp); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	TYPE=$(echo $i | awk -F'.' '{print $2}')
	SCA=$(cat $NAME.scaffolds.agp | awk '$5 == "U"' | wc -l)
	PAT=$(cat $NAME.patch.agp | awk '$5 == "N"' | wc -l)
	echo $NAME $SCA $PAT
done
