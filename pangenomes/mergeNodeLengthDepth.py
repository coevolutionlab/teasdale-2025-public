#!/usr/bin/env python
# coding: utf-8

import os
import sys
import argparse
import time
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('-l','--length', help = "node length file, should have header #node.id\tlength")
parser.add_argument('-d','--depth', help = "node depth output of odgi depth")
parser.add_argument('-o', '--mergedOutput', help = "output file name", required =True)

args = vars(parser.parse_args())

length = args['length']
depth = args['depth']
mergedOutput = args['mergedOutput']

print(f'input length :{length}')
print(f'input depth : {depth}')
print(f'output file : {mergedOutput}')

start = time.time()
#read length
nodeLengths = pd.read_table(length,)
#read depth
nodeDepths = pd.read_table(depth,)
#read merged
merged=pd.merge(nodeLengths, nodeDepths, how = "inner", on = ['#node.id'])
#write merged
merged.to_csv(mergedOutput,sep = "\t",index = None,)
stop = time.time()
print(f"\n time for processing input: {stop -start}")
