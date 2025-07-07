#!/bin/bash

export TMPDIR=../tmp/
export MEMORY=16.0

cat ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth0.CG_features.shuffled10Mill.txt.gz \
    ../output/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth1.CG_features.shuffled10Mill.txt.gz \
    |zcat|terashuf \
    > ../output/train_test_validation_sets/CG/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth0_Meth1.CG_features.shuffled10Mill.txt

head -n 19800000 ../output/train_test_validation_sets/CG/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth0_Meth1.CG_features.shuffled10Mill.txt \
    > ../output/train_test_validation_sets/CG/CG_train_test.txt
tail -n 200000 ../output/train_test_validation_sets/CG/at9852.merged.R1_bismark_bt2_pe.bedGraph.Meth0_Meth1.CG_features.shuffled10Mill.txt \
    > ../output/train_test_validation_sets/CG/CG_validate.txt


