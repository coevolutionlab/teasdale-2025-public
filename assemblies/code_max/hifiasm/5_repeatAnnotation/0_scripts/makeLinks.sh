#!/bin/bash

DATA=`cat paths*.txt`

for i in $DATA; do
	ln -s $i ./
done
