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
produce_list_of_fasta_ids.py [options]

OPTIONS:
-t list      The list of orthogroups

"""


def make_list(ortholog_list):
    with open(ortholog_list, 'r') as ortho_file:
        for line in ortho_file:
            orthogroup_line = line.strip()
            orthogroup_line_split = re.split(' |\t|, |: ', orthogroup_line)
            orthogroup_name = orthogroup_line_split.pop(0)
            for gene_id in orthogroup_line_split:
                print(orthogroup_name, gene_id, sep="\t", file=sys.stdout)
               


# If I am being run as a script...

if __name__ == '__main__':
    opts = docopt.docopt(CLI_ARGS)
    #fasta_files = opts['<FASTAFILES>']
    ortholog_list = opts['-t']
    
    
    make_list(ortholog_list)
    







