#!/usr/bin/env python3

####################
# p-distance calculator
####################

from __future__ import print_function
from __future__ import division
# the fasta parser
import screed
# for taking arguments from the command line
import sys
import argparse
import itertools

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description="""
p-distance calculator

lteasnail 20150505
v3 - lteasnail 20171006 (Luisa Teasdale)

This script will calculate the uncorrected pairwise-distance(p-distance)
between two specified sequences. P-distance is calculated by counting the
number of bases that differ between the two sequences and dividing the number
of differences by the length of the alignment minus any base pairs which are
missing in either sequence. The sequences need to be aligned and the alignments
need to be of the same length.

Updates:

Run as follows:

python p-distance_script.py -t dna -p average -s ~ -f *.fasta > average_distance_table.txt
python p-distance_script.py -t prot -p pairwise -a taxon1 -b taxon2 -s - -f *.fasta > pairwise_distance_table.txt

""")

parser.add_argument('-t', required=True, metavar='type of sequence', help='Specify if the sequence is "dna" or "prot".')
parser.add_argument('-f', required=True, nargs='+', metavar='f', help='The MSA fasta files.')
parser.add_argument('-p', required=True, metavar='pairwise or average', help='Specify whether you want to calculate the pairwise distances between two specified samples or the average distance for each alignment.')
parser.add_argument('-a', metavar='taxon1', help='If calculating pairwise distance, specify the exact header of the first taxon.')
parser.add_argument('-b', metavar='taxon2', help='If calculating pairwise distance, specify the exact header of the second taxon.')
parser.add_argument('-s', required=True, metavar='header delimitor', help='The character with which to split the headers. The script assumes that when you delimit the header based on this character the first part of the header will be unique to a taxon and the same across each fasta file.')


def read_in_fasta_and_calc_pairwise(fa_files, header_spliter, taxon1, taxon2, gaps):

    print("alignment_id", "pairwise_distance", "number_of_differences", "length_of_overlap", sep="\t", file=sys.stdout)

    for fafile in fa_files:
        # Find the two selected sequences and convert them to seperated lists
        for seq in screed.open(fafile):
            seq_sample = seq.name.split(header_spliter)[0]
            if seq_sample == taxon1:
                seq_1 = seq.sequence
                seq_1_split = list(seq_1)
                length = len(seq.sequence)
            elif seq_sample == taxon2:
                seq_2 = seq.sequence
                seq_2_split = list(seq_2)
            else:
                continue

        # Count the number of bases with missing data and
        # the number where the two sequences differ
        num_missing = 0
        num_diff = 0

        for base in range(len(seq_1_split)):
            if seq_1_split[base] in gaps or seq_2_split[base] in gaps:
                num_missing = num_missing + 1
            elif seq_1_split[base] != seq_2_split[base]:
                num_diff = num_diff + 1

        # Calulate and print the p-distance
        num_diff = float(num_diff)

        if set(seq_1_split) <= set(gaps) or set(seq_2_split) <= set(gaps):
            print(fafile, 'One_taxon_is_missing_the_sequence', 'na', 'na', sep="\t", file=sys.stdout)
        elif num_diff == 0:
            print(fafile, 'na', 'na', 'na', sep="\t", file=sys.stdout)
        else:
            pdistance = num_diff / (length - num_missing)
            part = length - num_missing
            pd = num_diff / part
            print(fafile, pd, int(num_diff), part, sep="\t", file=sys.stdout)


def read_in_fasta_and_calc_average(fa_files, header_spliter, gaps):

    print("taxa1", "taxa2", "average_pairwise_distance", sep="\t", file=sys.stdout)

    for fafile in fa_files:
        seq_names = []
        seqs = {}

        for seq in screed.open(fafile):
            seq_sample = seq.name.split(header_spliter)[0]
            print(seq_sample.split("|")[0], file=sys.stderr)
            if seq_sample.split("|")[0] != "arenosa": 
                seq_names.append(seq_sample)
                seq_1 = seq.sequence
                seq_1_split = list(seq_1)
                seqs[seq_sample] = seq_1_split
                length = len(seq.sequence)
            

        list_of_pairs = list(itertools.combinations(seq_names, 2))

        all_pair_wise_distances = []

        for pair in list_of_pairs:
            taxon1 = pair[0]
            taxon2 = pair[1]
            seq_1_split = seqs[taxon1]
            seq_2_split = seqs[taxon2]

            num_missing = 0
            num_diff = 0

            for base in range(len(seq_1_split)):
                if seq_1_split[base] in gaps or seq_2_split[base] in gaps:
                    num_missing = num_missing + 1
                elif seq_1_split[base] != seq_2_split[base]:
                    num_diff = num_diff + 1

        # Calulate and print the p-distance
            num_diff = float(num_diff)

            if set(seq_1_split) <= set(gaps) or set(seq_2_split) <= set(gaps):
                continue
            elif num_diff == 0:
                all_pair_wise_distances.append((pair, float(0)))
            else:
                part = length - num_missing
                pd = num_diff / part
                all_pair_wise_distances.append([pair, pd])
        sum_of_distances=0
        for item in all_pair_wise_distances:
            sum_of_distances += item[1]
        print(sum_of_distances, file=sys.stderr)
        print(float(len(all_pair_wise_distances)), file=sys.stderr)
        average = sum_of_distances / float(len(all_pair_wise_distances))
        print(fafile, average, sep="\t", file=sys.stdout)
        #print(all_pair_wise_distances, file=sys.stderr)
        for item in all_pair_wise_distances:
            pair = item[0]
            taxon1 = pair[0]
            taxon2 = pair[1]
            #distance = item.split(" ")[2]
            #distance_clean = distance.split("]")[0]
            #print(pair[0], pair[1], item[1], sep='\t', file=sys.stderr)


# If I am being run as a script...
if __name__ == '__main__':
    args = parser.parse_args()
    #s = args.s # max_num_samples per library
    t = args.t # type of sequence
    f = args.f # list_of_fasta_files
    p = args.p # pairwise or average
    a = args.a # taxon1
    b = args.b # taxon2
    s = args.s # header splitter character

    if t == "dna":
        gaps = {'-', '~', 'n', 'N'}
        if p == "pairwise":
            print("Calcuating pairwise hamming distance...", file=sys.stderr)
            read_in_fasta_and_calc_pairwise(f, s, a, b, gaps)
            print("Finished!", file=sys.stderr)
        elif p == "average":
            print("Calcuating average hamming distance... please be patient", file=sys.stderr)
            read_in_fasta_and_calc_average(f, s, gaps)
            print("Finished!", file=sys.stderr)
        else:
            print("Please specify whether you want to calculate 'pairwise' or 'average' distance. Formating for this argument such as ave or Pairwise is incorrect", file=sys.stderr)
    elif t == "prot":
        gaps = {'-', '~', 'x', 'X'}
        if p == "pairwise":
            print("Calcuating pairwise hamming distance...", file=sys.stderr)
            read_in_fasta_and_calc_pairwise(f, s, a, b, gaps)
            print("Finished!", file=sys.stderr)
        elif p == "average":
            print("Calcuating average hamming distance... please be patient", file=sys.stderr)
            read_in_fasta_and_calc_average(f, s, gaps)
            print("Finished!", file=sys.stderr)
        else:
            print("Please specify whether you want to calculate 'pairwise' or 'average' distance. Formating for this argument such as ave or Pairwise is incorrect", file=sys.stderr)
    else:
        print("Please specify whether the sequence type is dna or prot. Formating for this argument such as DNA or protein is incorrect", file=sys.stderr)
