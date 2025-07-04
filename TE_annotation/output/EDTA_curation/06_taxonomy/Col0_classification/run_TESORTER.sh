#!/usr/bin/env bash

THREADS=24

# Lines
TEsorter LINE.all.consensus.fa -db rexdb-line -p $THREADS
# LTR
TEsorter LTR.all.consensus.fa -db rexdb-plant -p $THREADS
# Sines
TEsorter SINE.all.consensus.fa -db sine -p $THREADS
# TIR
TEsorter DNA.all.consensus.fa -db rexdb-pnas  -p $THREADS
