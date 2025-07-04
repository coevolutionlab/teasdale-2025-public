#!/bin/bash

for line in $(cat contaminated.list); do
	find . -name $line*png  | xargs cp -t ~/thesis_figs_update/
done
