#!/bin/bash

for i in $(ls Orthogroups.txt); do
	cat $i | awk 'NF==2 {print $2}' | awk -F'_' '{print $1}' | sort | uniq -c
done
