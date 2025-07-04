#!/bin/bash

for i in $(ls at*Q20*.sh); do
	nice -n10 bash $i &
done
