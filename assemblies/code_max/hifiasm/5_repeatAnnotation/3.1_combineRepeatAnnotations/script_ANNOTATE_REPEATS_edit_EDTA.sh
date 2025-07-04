# USAGE:  # ./script_ANNOTATE_REPEATS_edit_EDTA.sh <WORKDIR> <ASSEMBLY> <input_EDTA> <ACC> <CORES>
# EXAMPLE # ./script_ANNOTATE_REPEATS_edit_EDTA.sh /ebio/abt6_projects8/rDNAevol/code/ANNOTATE_REPEATS <path_to_fasta> <path_to_EDTA.TEanno.gff3> Accession_name 24

# Parse parameteres
WORKDIR=$1
ASSEMBLY=$2
input_EDTA=$3
ACC=$4
CORES=$5

# Declare other variables
LIB=/ebio/abt6_projects8/rDNAevol/code/ANNOTATE_REPEATS/rDNA_centromeres6_telomeres.fa

parallel=$(( CORES / 4 ))
output=$WORKDIR/$ACC

# Required Software
source activate /ebio/abt6_projects8/alopecurus_genome/bin/anaconda2/envs/RepeatMasker_v4-0-9
BEDTOOLS=/ebio/abt6_projects9/abt6_software/bin/bedtools/bin/bedtools
SEQTK=/ebio/abt6_projects9/abt6_software/bin/seqtk/seqtk

# Create necessary directories
mkdir -p $output

cd $output

# Start
echo ""
echo "START script"
date

#############################################
############# ANNOTATE REPEATS ##############
#############################################

echo "Preparing Genome..."
# Copy reference genome to output directory (soft links became problematic)
cp $ASSEMBLY $output/$ACC.fa
chmod +w $output/$ACC.fa

# Make sure to change all lower-case to UPPER-case
sed -i -e '/>/b; s/a/A/g; s/c/C/g; s/g/G/g; s/t/T/g' $output/$ACC.fa

# Index reference for future usage
samtools faidx $output/$ACC.fa

echo "Running RepeatMasker..."
RepeatMasker -lib $LIB -pa $parallel -cutoff 200 -nolow -gff -xsmall $output/$ACC.fa

echo "Re-formatting gff2 to gff3..."
sed "s/\"//g" $output/$ACC.fa.out.gff > $output/$ACC.gff2
sed -i "s/Motif:/Repeat_type=/g" $output/$ACC.gff2

# For rDNA (DNA including ITS and ETS)
grep "=5S_rDNA" $output/$ACC.gff2 | awk -v OFS='\t' '{print $1, $2, "5S_rDNA", $4, $5, ".", $7, $8, "ID=5S_rDNA_"NR";"$10";Length="$12-$11";Divergence="$6""  }' > $output/$ACC.5S_rDNA.gff
grep "=45S_rDNA" $output/$ACC.gff2 | awk -v OFS='\t' '{print $1, $2, "45S_rDNA", $4, $5, ".", $7, $8, "ID=45S_rDNA_"NR";"$10";Length="$12-$11";Divergence="$6""  }' > $output/$ACC.45S_rDNA.gff

# Other repeats
grep "=centromere" $output/$ACC.gff2 | awk -v OFS='\t' '{print $1, $2, "centromere", $4, $5, ".", $7, $8, "ID=centromere_"NR";"$10";Length="$12-$11";Divergence="$6""  }' > $output/$ACC.centromere.gff
grep "=telomere" $output/$ACC.gff2 | awk -v OFS='\t' '{print $1, $2, "telomere", $4, $5, ".", $7, $8, "ID=telomere_"NR";"$10";Length="$12-$11";Divergence="$6""  }' > $output/$ACC.telomere.gff

conda deactivate

#############################################
############### N-stretches #################
#############################################

echo "Identifying N-stretches..."
$SEQTK cutN -n 10 -g -p 1000000000000 $output/$ACC.fa > $output/$ACC.TMP.txt
awk -F"\t" -v OFS="\t" '{$4=$3-$2}1' $output/$ACC.TMP.txt > $output/$ACC.N.txt

echo "Convert previously generated N-stretches file into GFF..."
awk -v OFS='\t' '{print $1, "seqtk", "N_stretch", $2, $3, ".", "+", ".", "ID=N_stretch_"NR";Length="$4""  }' $output/$ACC.N.txt > $output/$ACC.N.gff

#############################################
############### Normal OUTPUT ###############
#############################################

# Concatenate GFF files from RepeatMasker, N_stretches and minimap2
cat $output/$ACC.*_rDNA.gff \
	$output/$ACC.centromere.gff \
	$output/$ACC.telomere.gff \
	$output/$ACC.N.gff \
	> $output/$ACC.Repeats.TMP.gff

# Sort GFF files
sort -k1,1 -k4n $output/$ACC.Repeats.TMP.gff > $output/$ACC.Repeats.gff

sed -i '1i ##gff-version 3' $output/$ACC.Repeats.gff
sed -i "2i ##date $(date +%Y-%m-%d)" $output/$ACC.Repeats.gff

input_REPEATS=$output/$ACC.Repeats.gff

echo "Removing unnecessary files..."
rm $output/$ACC.fa.out.gff
rm $output/$ACC.fa.masked
rm $output/$ACC.TMP.txt
rm $output/$ACC.Repeats.TMP.gff


########################################################
################## Merge OVERLAPS ######################
########################################################

echo "Merging overlapping annotations – rDNA..."
# 45S
$BEDTOOLS merge -i $output/$ACC.45S_rDNA.gff -c 1 -o count > $output/$ACC.45S_rDNA.out
awk -v OFS='\t' '{print $1, "RepeatMasker", "45S_rDNA", $2+=1, $3, ".", "+", ".", "ID=45S_rDNA_"NR";Repeat_type=45S_rDNA;Length="$3-$2";Merged="$4"" }' $output/$ACC.45S_rDNA.out > $output/$ACC.45S_rDNA.merged.gff
# 5S
$BEDTOOLS merge -i $output/$ACC.5S_rDNA.gff -c 1 -o count > $output/$ACC.5S_rDNA.out
awk -v OFS='\t' '{print $1, "RepeatMasker", "5S_rDNA", $2+=1, $3, ".", "+", ".", "ID=5S_rDNA_"NR";Repeat_type=5S_rDNA;Length="$3-$2";Merged="$4"" }' $output/$ACC.5S_rDNA.out > $output/$ACC.5S_rDNA.merged.gff

echo "Merging overlapping annotations – centromeres..."
# centromere
$BEDTOOLS merge -i $output/$ACC.centromere.gff -c 1 -o count > $output/$ACC.centromere.out
awk -v OFS='\t' '{print $1, "RepeatMasker", "centromere", $2+=1, $3, ".", "+", ".", "ID=centromere_"NR";Repeat_type=centromere;Length="$3-$2";Merged="$4"" }' $output/$ACC.centromere.out > $output/$ACC.centromere.merged.gff

echo "Merging overlapping annotations – telomeres..."
# telomere
$BEDTOOLS merge -i $output/$ACC.telomere.gff -c 1 -o count > $output/$ACC.telomere.out
awk -v OFS='\t' '{print $1, "RepeatMasker", "telomere", $2+=1, $3, ".", "+", ".", "ID=telomere_"NR";Repeat_type=telomere;Length="$3-$2";Merged="$4"" }' $output/$ACC.telomere.out > $output/$ACC.telomere.merged.gff

echo "Concatenating GFF files..."
## Concatenate GFF files after merging steps
cat $output/$ACC.*_rDNA.merged.gff \
	$output/$ACC.centromere.merged.gff \
	$output/$ACC.telomere.merged.gff \
	$output/$ACC.N.gff \
	> $output/$ACC.Repeats_merged.TMP.gff

# Sort GFF files
sort -k1,1 -k4n $output/$ACC.Repeats_merged.TMP.gff > $output/$ACC.Repeats_merged.gff
sed -i '1i ##gff-version 3' $output/$ACC.Repeats_merged.gff
sed -i "2i ##date $(date +%Y-%m-%d)" $output/$ACC.Repeats_merged.gff

input_REPEATS_merged=$output/$ACC.Repeats_merged.gff

echo "Removing unneccesary files..."
rm $output/$ACC.*.out
rm $output/$ACC.Repeats_merged.TMP.gff

########################################
############ Simplify TEs ##############
########################################

echo "Removing signatures of LTRs..."
grep -v "ID=repeat_" $input_EDTA > $output/$ACC.EDTA.TMP1.gff3
grep -v "long_terminal_repeat" $output/$ACC.EDTA.TMP1.gff3 > $output/$ACC.EDTA.TMP2.gff3
grep -v "target_site_duplication" $output/$ACC.EDTA.TMP2.gff3 > $output/$ACC.EDTA.TEanno.edit.gff3

echo "Classifying TEs..."
sed -i 's/Copia_LTR_retrotransposon/ClassI_LTR/' $output/$ACC.EDTA.TEanno.edit.gff3
sed -i 's/Gypsy_LTR_retrotransposon/ClassI_LTR/' $output/$ACC.EDTA.TEanno.edit.gff3
sed -i 's/LTR_retrotransposon/ClassI_LTR/' $output/$ACC.EDTA.TEanno.edit.gff3

sed -i 's/LINE_element/ClassI_nonLTR/' $output/$ACC.EDTA.TEanno.edit.gff3

sed -i 's/CACTA_TIR_transposon/ClassII_TIR/' $output/$ACC.EDTA.TEanno.edit.gff3
sed -i 's/hAT_TIR_transposon/ClassII_TIR/' $output/$ACC.EDTA.TEanno.edit.gff3
sed -i 's/Mutator_TIR_transposon/ClassII_TIR/' $output/$ACC.EDTA.TEanno.edit.gff3
sed -i 's/PIF_Harbinger_TIR_transposon/ClassII_TIR/' $output/$ACC.EDTA.TEanno.edit.gff3
sed -i 's/Tc1_Mariner_TIR_transposon/ClassII_TIR/' $output/$ACC.EDTA.TEanno.edit.gff3

sed -i 's/helitron/ClassII_Helitrons/' $output/$ACC.EDTA.TEanno.edit.gff3

rm $output/$ACC.EDTA.TMP*

##########################################
############ EDTA + REPEATS ##############
##########################################

echo "# Processing EDTA.gff to filter out 'TEs' overlapping rDNAs (input_REPEATS_merged)..."
# "Only report those entries in A that have no overlap in B. Restricted by -f and -r."
$BEDTOOLS intersect -v -a $output/$ACC.EDTA.TEanno.edit.gff3 -b $input_REPEATS_merged > $output/EDTA_rDNAPurged.v.gff

# "Perform a “left outer join”. That is, for each feature in A report each overlap with B. If no overlaps are found, report a NULL feature for B." 
$BEDTOOLS intersect -loj -a $output/$ACC.EDTA.TEanno.edit.gff3 -b $input_REPEATS_merged > $output/EDTA_rDNAPurged.loj.gff

# Concatenate Repeats and TE annotations (only those that do not overlap) 
cat $input_REPEATS_merged $output/EDTA_rDNAPurged.v.gff > $output/$ACC.Repeats_TEanno.TMP1.gff3

# Remove header and sort
grep -v "^#"  $output/$ACC.Repeats_TEanno.TMP1.gff3 > $output/$ACC.Repeats_TEanno.TMP2.gff3
sort -k1,1 -k4n $output/$ACC.Repeats_TEanno.TMP2.gff3 > $output/$ACC.Repeats_TEanno.gff3

sed -i '1i ##gff-version 3' $output/$ACC.Repeats_TEanno.gff3
sed -i "2i ##date $(date +%Y-%m-%d)" $output/$ACC.Repeats_TEanno.gff3

# BEFORE and AFTER TE count
echo "TEs BEFORE purging:"
grep -c -v "^#" $output/$ACC.EDTA.TEanno.edit.gff3
echo "TEs AFTER purging:"
grep -c -v "^#" $output/EDTA_rDNAPurged.v.gff

rm $output/$ACC.Repeats_TEanno.TMP*

date
echo "END script"
echo ""
