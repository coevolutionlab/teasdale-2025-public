#!/usr/bin/env python3

from __future__ import print_function
from os import path

import docopt
import sys
import screed
import re
from collections import defaultdict

#You a bunch of clstr files from cd-hit and you want to know how many clusters each file contains, and which sequences belong to which cluster


__author__ = "lteasnail"

CLI_ARGS = """
USAGE:
cd-hit_output_parser.py <CLSTRFILES>...

"""


def parse_clstr(clstrfiles):
    clstr_dict = defaultdict(list)
    for clstr_file in clstrfiles:
        cluster_counter = 0
        with open(clstr_file, 'r') as cf:
            for line in cf:
                if line[0] == ">":
                    cluster_counter += 1
                    seq_counter = 0
                    cluster_id = "cluster_" + str(cluster_counter)
                else:
                    seq_counter += 1
                    seq_id = line.split(">")[1]
                    seq_id2 = seq_id.split("_mRNA")[0]
                    seq_id3 = seq_id2.split(".")[0]
                    #print(line, file=sys.stderr)
                    #print(seq_id, file=sys.stderr)
                    cluster_id = clstr_file.split("_90")[0] + "-cluster-" + str(cluster_counter)
                    print(clstr_file.split("_90")[0], cluster_id, seq_id3, sep="\t", file=sys.stdout)
            #print(clstr_file.split("_85")[0], cluster_id, seq_counter, sep="\t", file=sys.stderr)
            print(clstr_file.split("_90")[0], cluster_counter, sep="\t", file=sys.stderr)
                


# If I am being run as a script...

if __name__ == '__main__':
    opts = docopt.docopt(CLI_ARGS)
    clstr_files = opts['<CLSTRFILES>']
    
    
    parse_clstr(clstr_files)

