#!/usr/bin/env python
# coding: utf-8
## Author: Gautam Shirsekar #####
### use python makeHaploidToPseudoDiploidVCF.py -h for the help with menu



import polars as pl
import os
import sys
import argparse
import time

parser = argparse.ArgumentParser()
parser.add_argument('-i','--input', help = "input vcf file")
parser.add_argument('-o','--output', help = "output vcf prefix")
parser.add_argument('-s', '--separator', default = "unphased", type = str, help = "separator string \n it can be 'unphased(default)', or 'phased' ", required =False)

args = vars(parser.parse_args())

invcf = args['input']
outvcfprefix = args['output']
separator = args['separator']

print(f'input vcf :{invcf}')
print(f'output vcf : {outvcfprefix}.pDiploid.vcf')

# In[ ]: Processing Input

start = time.time()
os.system(f'grep "^#" {invcf}| head -n -1 > header.txt')
os.system(f'grep -A 1000000000 "CHROM" {invcf} > {outvcfprefix}.txt')
stop = time.time()

print(f"\n time for processing input: {stop -start}")


# In[4]: Manipulating Input

txtFile = f'{outvcfprefix}.txt'

start = time.time()
df = pl.scan_csv(txtFile, sep="\t")

def convertDiploid(fileprefix, columnsToExclude=9, seperator=str(separator)):
    outfile = f'{fileprefix}.diploid.txt'
    infile = f'{fileprefix}.txt'

    if seperator == "phased":
        sepString = "|"
    elif seperator == 'unphased':
        sepString = "/"
    else:
        print('wrong choice for separator (use <phased> or <unphased>)')

    df = pl.scan_csv(
        infile,
        sep="\t",
        infer_schema_length=0,
        #null_values = {".":str(".|.")},
        #ignore_errors = True,
    )

    (
        df
        .select
        (
            [
                pl.exclude(df.columns[columnsToExclude:]), # exclude first 9 columns
                pl.col(df.columns[columnsToExclude:]).apply(lambda x: f'{x}{sepString}{x}'), # make it pseudo-diploid
            ]
        )
        .collect()
        .write_csv(outfile, sep="\t",)
    )
    return 0


#executing function
convertDiploid(outvcfprefix,9,separator)
stop = time.time()

print(f"\n time for polars manipulation of input: {stop -start}")

#Formatting output
start = time.time()
os.system(f'cat header.txt {outvcfprefix}.diploid.txt > {outvcfprefix}.pDiploid.vcf')
stop = time.time()

print(f"\n time for formatting output: {stop -start}")



