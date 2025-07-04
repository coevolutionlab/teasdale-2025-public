#! /usr/bin/python3
import sys
import os.path

'''
Format cd-ht output file
'''
fin = sys.argv[1]


with open(fin, 'r') as fin:
    for line in fin:
        line = line.rstrip()
        line = line.lower()
        if line[0] == ">": header = line
        elif line[0] != ">": ind = line ; print(header + "\t" + ind, file=sys.stdout)
