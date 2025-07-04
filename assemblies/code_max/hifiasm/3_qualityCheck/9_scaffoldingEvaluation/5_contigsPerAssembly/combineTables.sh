#!/bin/bash

for line in $(cat contigNumber.4R); do
	NAME=$(echo $line | awk -F';' '{print $1}')
	
