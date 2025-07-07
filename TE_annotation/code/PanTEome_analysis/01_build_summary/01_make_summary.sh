#!/usr/bin/env bash


# TE annotation:
TE_annotation="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/final_TE_annotation/pangenome_TEannotation.gff3"
pangenome="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/final_TE_annotation/pangenome.fasta"

# Here we make a new, repeatmasker style, summary output to include the new TEmodels. 
# VAR

output_dir="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/TE_analysis/01_build_summary/repeatmasker_new_lib"
run_repeatmasker="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/PanTEome_analysis/01_build_summary/run_repeatmasker.sh"
THREADS=24

#####
# parepare files
mkdir -p $output_dir
cd $output_dir
ln -s /ebio/abt6_projects7/diffLines_20/data/TE_annotation/output/final_TE_annotation/pangenome.TElib.newTEfams.fa
for fasta in  /ebio/abt6_projects7/diffLines_20/data/TE_annotation/input/genomes/*.fasta  ; do 
	ln -s $fasta . ; 
done 

######

# Run repeatmasker for each assembly to create an out file 

for fasta in at*fasta ; do 
	bash $run_repeatmasker  -g $fasta -l pangenome.TElib.newTEfams.fa -t $THREADS ; 
done 


# Calcualte divergence:

# Scripts used
calcDivergence="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/EDTA_utils/calcDivergenceFromAlign.pl"
count_base_pl="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/EDTA_utils/count_base.pl"
buildSummary_pl="/ebio/abt6_projects7/diffLines_20/data/TE_annotation/code/EDTA_utils/buildSummary.pl"


for align_file in *.align ; do 

	 perl ${calcDivergence} -s $(basename $align_file .align).divsum  $align_file  ;
	 tail -n 72  $(basename $align_file .align).divsum  > $(basename $align_file .align).divsum.72 ;

done


# Now we are going to clean and modify the rest of the divsum file:


for divsum in  *.fasta.divsum  ; do 
	# retireve main body:
	tail -n +7  ${divsum} | head -n -75 |
	#  change second column
	awk '{if ($2 ~ /^AT/) {sub(/^AT[^_]+_/, "", $2);} print; }' |
	# squeeze whitespaces and change them for tabs
	tr -s ' ' | tr ' ' '\t' |
 	# drop first column 
	cut -f2-  |
	# Add a header line 
	sed '1 i\Repeat\tabsLen\twellCharLen\tKimura%' > $(basename ${divsum} .divsum).mod.divsum  ; 
done

# Now we are going to modify the out file and remove 45_SrDNA, 5S_rDNA CEN  and telomere sequences from it.
# Then we are going to recalculate the sum (Summary) file.


for  fasta  in *.fasta ; do 
	# Get the out file: 
	out_file=${fasta}.out
	# Clean the OUT file:
	cat $out_file | sed 's/LINE?/LINE/g;
	s/LINE\/L1/LINE/g;
	s/LINE\/unknown/LINE/g;
	s/RathE[1,2,3]_cons/SINE/g;
	s/DNA\/helitron/RC\/Helitron/g;
	s/LTR_retrotransposon/\tLTR_unknown/g;
	s/Gypsy_LTR_retrotransposon\t/LTR_Ty3\t/g;
	s/L1_LINE_retrotransposon/LINE/g;
	s/telomere\/telomere/telomere/g;
	s/DTA/HAT/g;
	s/DTC/CACTA/g;
	s/DTH/Harbinger/g;
	s/DTM/Mutator/g;
	s/DTT/Mariner/g;
	s/EnSpm/CACTA/g;
	s/MuDR/Mutator/g;
	s/Pogo/Mariner/g;
	s/Tc1/Mariner/g;
	s/Copia/Ty1/g;
	s/Gypsy/Ty3/g;
	s/TIR\/CACTA_CACTA/DNA\/CACTA/g;
	s/DNA\/Helitron/RC\/Helitron/g;
	s/\/CEN[1-6]//g;
	s/45S_//g;
	s/5S\///g;
	s/Chr[3-5]//g;
	s/rDNA_/rDNA/g' |
	grep -v "CEN" |
	grep -v "rDNA" |
	grep -v "telomere" |
	awk '{if ($10 ~ /^AT/) {sub(/^AT[^_]+_/, "", $10);} print; }'  >  $(basename ${out_file} .out).mod.out ;
	# Count stats: 
	perl ${count_base_pl} $fasta > ${fasta}.stats ;
	# BuildSummary file:
	perl $buildSummary_pl  -maxDiv 40   $(basename ${out_file} .out).mod.out  >  $(basename ${out_file} .out).mod.sum ;

done 


###############################################
# Compile all stats per single genome together:


# Compile mod divsum:

for divsum in  repeatmasker_new_lib/at*mod.divsum ; do 
	genome=$(basename $divsum .fasta.mod.divsum) ;
	tail -n +2 ${divsum} |
	awk -v genome=$genome '{print genome"\t"$0}' ;
done | sed '1 i\Accession\tRepeat\tabsLen\twellCharLen\tKimura%' > pangenome_divsum_stats.tsv


# The sum file  is harder to parse, so we need to make a function first:


parse_sum_file() {
    local filename=$1
    local accession=$2
    local repeat_classes_file="${accession}_Repeat_classes.tsv"
    local repeat_stats_file="${accession}_Repeat_stats.tsv"
    local writing_file=$repeat_classes_file
    local skip_stats=false

      while IFS= read -r line; do
        if [[ $line == "Repeat Classes"* ]]; then
            writing_file=$repeat_classes_file
            skip_stats=false
        elif [[ $line == "Repeat Stats"* ]]; then
            writing_file=$repeat_stats_file
            skip_stats=false
        elif [[ $line == "--------------------------------------------------------" ]]; then
            skip_stats=true
            continue
        elif [[ $line == Total* || $line == *"="* || $skip_stats == true ]]; then
            continue
        fi

        echo -e "${line}" >> "$writing_file"
    done < "$filename"

    echo "Created $repeat_classes_file"
    echo "Created $repeat_stats_file"

}

export -f parse_sum_file



# Create the files in a loop  in the repeatmasker_new_lib/ folder
cd repeatmasker_new_lib/
for sum_file in  at*.fasta.mod.sum ; do 
	name=$(basename ${sum_file} .fasta.mod.sum) ;
	parse_sum_file $sum_file $name ;
done

cd ../

# parse all the stats:

for repeat_stat_file in repeatmasker_new_lib/at*_Repeat_stats.tsv ; do
	name=$(basename $repeat_stat_file  _Repeat_stats.tsv) ; 
	# Parse file
	tail -n +3 $repeat_stat_file |
	awk -v name=$name '{print name"\t"$1"\t"$2"\t"$3"\t"$4}' ;
done | sed '1 i\Accession\tID\tCount\tbpMasked\t%masked' > pangenome_repeat_stats.tsv

echo "DONE!" 