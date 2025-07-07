#!/usr/bin/env python3

from __future__ import print_function
from os import path

import docopt
import sys
import screed
import re
from collections import defaultdict

# You have fasta files with all sequences per sample
# You have a list with names
# First reformate the list
# then produce fasta files with all sequences per ortho group

__author__ = "lteasnail"

CLI_ARGS = """
USAGE:
produce_list_of_fasta_ids.py <FASTAFILES>...

"""


def make_list(fastafiles):
    for fasta_file in fastafiles:
        seqs = screed.open(fasta_file)
        for seq in seqs:
            seq_name = seq.name
            fasta_file_name = fasta_file
            print(fasta_file, seq_name, sep="\t", file=sys.stdout)



# If I am being run as a script...

if __name__ == '__main__':
    opts = docopt.docopt(CLI_ARGS)
    fasta_files = opts['<FASTAFILES>']
    #ortholog_list = opts['-t']
    
    
    make_list(fasta_files)








