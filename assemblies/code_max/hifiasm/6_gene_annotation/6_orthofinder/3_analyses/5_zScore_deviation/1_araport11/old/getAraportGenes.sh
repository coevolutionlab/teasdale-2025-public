#!/bin/bash


for line in $(cat test); do
	grep -w $line orthogroups.txt >> araport11.UP.ids
done
