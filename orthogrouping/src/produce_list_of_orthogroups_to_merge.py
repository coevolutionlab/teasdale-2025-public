#!/usr/bin/env python3

from __future__ import print_function
from os import path

import docopt
import sys
import screed
import re
from collections import defaultdict

#You have fasta files with all sequences per sample
#You have a list with names
#First reformate the list
#then produce fasta files with all sequences per ortho group

__author__ = "lteasnail"

CLI_ARGS = """
USAGE:
produce_list_of_orthogroups_to_merge.py -t list

OPTIONS:
-t list      The list of orthogroups to be merged

"""


def make_list(ortholog_list):
    pairs_list = []
    with open(ortholog_list, 'r') as ortholog_l:
        for line in ortholog_l:
            line2 = line.strip()
            pair_members = re.split(' |\t|, |: ', line2)
            pairs_list.append((pair_members[0],pair_members[1]))
    return pairs_list
               
def cluster_pairs(pairs):
    clusters = []
    for pair in pairs:
        found = False
        for cluster in clusters:
            if any(item in cluster for item in pair):
                cluster.update(pair)
                found = True
                break
        if not found:
            clusters.append(set(pair))

    # Convert clusters to tuples and return
    clustered_pairs = [tuple(cluster) for cluster in clusters]
    for item in clustered_pairs:
        print(item, file=sys.stdout)
    #return clustered_pairs
    
    
    
def cluster_pairs2(pairs):
    clusters = []
    for pair in pairs:
        found_cluster = None
        for cluster in clusters:
            if any(item in cluster for item in pair):
                found_cluster = cluster
                break
        if found_cluster is not None:
            found_cluster.update(pair)
        else:
            clusters.append(set(pair))
    clustered_pairs = [tuple(cluster) for cluster in clusters]
    for item in clustered_pairs:
        print(item, file=sys.stdout)
        

def mergepairs(pairs):
    out = {}
    for pair in pairs:
        a, b = pair
        if a in out and b in out:
            new = out[a] | out[b]
        elif a in out and b not in out:
            new = out[a] | set([b, ])
        elif a not in out and b in out:
            new = out[b] | set([a, ])
        else:
            new = set([a, b])
        for i in new:
            out[i] = new
    sets = set()
    for o in out.values():
        sets.add(tuple(sorted(o)))
    #print(sets, file=sys.stdout)
    for item in sets:
        print(item, file=sys.stdout)


# If I am being run as a script...

if __name__ == '__main__':
    opts = docopt.docopt(CLI_ARGS)
    #fasta_files = opts['<FASTAFILES>']
    ortholog_list = opts['-t']
    
    
    pairs = make_list(ortholog_list)
    #print(pairs, file=sys.stderr)
    mergepairs(pairs)
    







