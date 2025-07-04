#!/bin/bash

for i in $(ls at*liftoff3.aa); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	sed -i -e "s/>/>$NAME\_/g" $i &
done
