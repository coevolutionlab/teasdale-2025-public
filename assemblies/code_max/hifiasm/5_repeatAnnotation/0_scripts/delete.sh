#!/bin/bash

DATA=`cat names2delete`

for i in $DATA; do
	qdel $i 
done
