#!/usr/bin/env python3
#Libraries
import os
import sys
import argparse
import time
import pandas as pd
import multiprocessing as mp
import numpy as np
from joblib import Parallel, delayed


### Arguments #####
myparser = argparse.ArgumentParser()
myparser.add_argument("-i",type=str, help= "features file (should be gzipped)")
myparser.add_argument("-o", type = str, help = "output file, will be gzipped")
myparser.add_argument("-s", type = int, help ="random seed", default = 123)
myparser.add_argument("-n", type = int, help ="number of cpu", default = 4)

args = myparser.parse_args()

inputfile = args.i
outfile = args.o
randomSeed = args.s
numcpu = args.n

start = time.time()
if os.path.exists(outfile):
    print(f'file exists, removing existing {outfile}')
    os.remove(outfile)
    print(f'shuffling started')
else:
    print(f'shuffling started')

### global fraction
global fraction
fraction = 1.0 # since we want to reshuffle the sample everything

### functions used in this script ######
def randomSample(df):
    dfsample = df.sample(frac=fraction, random_state = randomSeed)
    return dfsample


def parallel(dataframe, func):
    dataframe_split = np.array_split(dataframe, numcpu)
    pool = mp.Pool(numcpu)
    dataframe_return = pd.concat(pool.map(func, dataframe_split), ignore_index = True)
    pool.close()
    return dataframe_return

def write_csv(df, outfile):
    df.to_csv(outfile, sep ='\t',compression = 'gzip', header =None, index = None)


# if sufficient memory exists then commented out portion is without chunking
reader = pd.read_csv(inputfile, sep = '\t', compression = 'gzip', header = None)
df = parallel(reader, randomSample)

parts = np.array_split(df, numcpu)
Parallel(n_jobs = numcpu)(delayed(write_csv)(part, f'{outfile}_part_{i}') for i, part in enumerate(parts))
bashcommand = 'cat '+ outfile +'_part_* >' + outfile
os.system(bashcommand)
os.system('rm '+outfile+'_part_*')

stop = time.time()
print(f'time taken = {stop -start}')
