#!/bin/bash

for i in $(cat jobs2delete.txt); do
	qdel $i
done
