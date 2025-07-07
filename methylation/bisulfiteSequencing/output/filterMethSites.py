#!/usr/bin/env python3
import pandas as pd
import os
import sys
import argparse
import multiprocessing as mp
import time


myparser = argparse.ArgumentParser()
myparser.add_argument("-i",type=str, help= "features file (should be gzipped)")
myparser.add_argument('-p',type=str, help= "positions file (tab delimited file, should be gzipped")
myparser.add_argument("-o", type = str, help = "output file, will be gzipped")
myparser.add_argument("-c", type = int, help ="chunksize")
myparser.add_argument("-nc", type=int, help="number of cpu cores")


args = myparser.parse_args()
inputfile = args.i #input feature file
positionfile = args.p # position file
outfile = args.o
chunksize = args.c
numcpu = args.nc

start = time.time()
### if the result file is already present in the directory then delete it
if outfile:
    bashcommand = 'rm ' + outfile
    os.system(bashcommand)


#read position file
df_positions = pd.read_csv(positionfile, sep = "\t", compression = 'gzip',  names = ['chr', 'position'],)
df_positions['exact']=df_positions['chr'] +"-"+ df_positions["position"].astype(str)

# function for filtering the positions that are in the features file
def filter(df,df_positions=df_positions):
    df.rename(columns={0:'chr', 1:'position'},inplace = True)
    #df_results_subset = df[(df['chr'].isin(df_positions['chr'])) & (df['position'].isin(df_positions['position']))]
    df['exact']=df['chr'] +"-"+ df["position"].astype(str)
    df_results_subset = df[df['exact'].isin(df_positions['exact'])]
    df_results_subset_mod= df_results_subset.drop(['exact'], axis=1,)
    return df_results_subset_mod

# read the features file (input) into chunks
reader = pd.read_csv(inputfile, sep="\t", compression="gzip", chunksize = chunksize, header = None)
# divide the job in number of cpus where each chunk can be processed separately
pool = mp.Pool(numcpu)
print(f'cores used = {numcpu}')

#gather results from all the chunks into resultlist
#resultlist = []
for i,chunk in enumerate(reader):
    print(f'processing chunk {i}')
    f = pool.apply_async(filter, [chunk, df_positions])
    #resultlist.append(f)
    pd.DataFrame(f.get()).to_csv(outfile, mode = 'a', sep ='\t', header = None, index = None)
'''#process the results from resultlist
result = []
for f in resultlist:
    result.append(f.get())
    print(f.get())
#concatenate all the result lists and write to a file
grandresult = pd.concat(result)
grandresult.to_csv(outfile, sep="\t", header =None, index = None)
'''
stop = time.time()

print(f'time taken = {stop - start}')
