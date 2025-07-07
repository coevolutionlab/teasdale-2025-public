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
fasta_formater_general_with_a_list.py [options] <FASTAFILES>...

OPTIONS:
-t list      The list of orthologs

"""


def reformat(fastafiles):
    Gene_model_dict = defaultdict(list)
    for fasta_file in fastafiles:
        seqs = screed.open(fasta_file)
        for seq in seqs:
            seq_name = seq.name
            seq_name2 = re.split(' |\t|, |: ', seq_name)
            #print(seq_name2[0], file=sys.stderr)
            seq_name3 = re.split(' |\t|, |: |_', seq_name2[0])[0] + "_" + re.split(' |\t|, |: |_', seq_name2[0])[1]
            print(seq_name3, file=sys.stderr)
            seq_sequence = seq.sequence
            #print(seq_sequence, file=sys.stderr)
            Gene_model_dict[seq_name3] = seq_sequence
    return Gene_model_dict


def reformat2(fastafiles):
    Gene_model_dict = defaultdict(list)
    for fasta_file in fastafiles:
        seqs = screed.open(fasta_file)
        for seq in seqs:
            seq_name = seq.name
            #print(seq_name, file=sys.stderr)
            seq_name3 = re.split('(\_mRNA)', seq_name)[0]
            #seq_name3 = re.split(r'\.|\s', seq_name)[0]
            #print(seq_name3, file=sys.stderr)
            seq_sequence = seq.sequence
            #print(seq_sequence, file=sys.stderr)
            Gene_model_dict[seq_name3] = seq_sequence
    #print(Gene_model_dict, file=sys.stderr)
    return Gene_model_dict


def process_ortholog_list(Gene_model_dict, ortholog_list):
    for line in ortholog_list:
        print(line, file=sys.stderr)
        ortho_set1 = line.strip()
        ortho_set2 = re.split(' |\t|, |: ', ortho_set1)
        ortho_set = list(filter(None, ortho_set2))
        #print(ortho_set)
        ortho_name = ortho_set[0] + ".fa"
        rest_of_list = ortho_set[1:]
        #print(rest_of_list)
        with open(ortho_name, 'w') as ortho_file:
            for ID in rest_of_list:
                #print(ID)
                name = ID
                sequence = Gene_model_dict[ID]
                typee = type(sequence)
                #print(typee)
                state = isinstance(typee, list)
                #print(state)
                if len(sequence) > 1:
                    print(">" + name + "\n" + sequence, file=ortho_file)
                    

def process_ortholog_list_text(ortholog_list):
    orthogroup_dic = defaultdict(list)
    type_dic = defaultdict(list)
    for line in ortholog_list:
        ortho_set1 = line.strip()
        if not ortho_set1:
            continue
        ortho_set2 = re.split(' |\t|_mRNA\t', ortho_set1)
        if len(ortho_set2) != 3:
            print(ortho_set2, file=sys.stderr)
            continue
        #print(ortho_set1, file=sys.stderr)
        #print(ortho_set2, file=sys.stderr)
        seq_name = ortho_set2[0]
        orthogroup = ortho_set2[1]
        typee = ortho_set2[2]
        orthogroup_dic[orthogroup].append(seq_name)
        type_dic[seq_name].append(typee)
        #print(orthogroup, seq_name, file=sys.stderr)
    return orthogroup_dic, type_dic



def process_ortholog_list_print_sequences(Gene_model_dict, orthogroup_dic, type_dic):
    for orthogroup in orthogroup_dic:
        ortho_name = orthogroup + "_aa.fa"
        rest_of_list = orthogroup_dic[orthogroup]
        #print(rest_of_list)
        with open(ortho_name, 'w') as ortho_file:
            for ID in rest_of_list:
                #print(ID)
                name = ID
                sequence = Gene_model_dict[ID]
                label = type_dic[ID]
                actual_label = label[0]
                typee = type(sequence)
                #print(typee)
                state = isinstance(typee, list)
                #print(state)
                if len(sequence) > 1:
                    print(">" + name +"_" + actual_label + "\n" + sequence, file=ortho_file)
                    
                    


# If I am being run as a script...

if __name__ == '__main__':
    opts = docopt.docopt(CLI_ARGS)
    fasta_files = opts['<FASTAFILES>']
    ortholog_list = opts['-t']
    
    
    Gene_model_dict = reformat2(fasta_files)
    
    with open(ortholog_list, 'r') as ol:
            orthogroup_dic, type_dic = process_ortholog_list_text(ol)
            process_ortholog_list_print_sequences(Gene_model_dict, orthogroup_dic, type_dic)
