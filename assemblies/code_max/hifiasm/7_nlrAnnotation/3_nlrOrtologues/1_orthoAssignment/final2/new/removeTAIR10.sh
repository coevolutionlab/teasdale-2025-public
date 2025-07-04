#!/bin/bash

for i in $(ls *NBS*.4R); do 
	NAME=$(echo $i | awk -F'.4R' '{print $1}')
	cat $i | awk '$2 != "TAIR10"' > $NAME.new.4R
done
