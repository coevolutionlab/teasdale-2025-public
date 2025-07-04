#!/bin/bash

for i in $(ls at*.aa); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	sed -i -e "s/>/>$NAME\_/g" $i &
done
