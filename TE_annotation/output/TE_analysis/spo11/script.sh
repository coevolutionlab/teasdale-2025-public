#!/usr/bin/env bash

set -e
set -u
set -o pipefail

### MAIN ####
# MAKE FILE ARRAYS
reg_arr=(global $(ls *anno_feature/*.bed))
#Group_arr=($(ls ${TE_anno}/Feature_*.bed)) #If I want to breakdown the TE anno per family or Feature
Group_arr=( $(ls spo11_threshold/spo11_*.bed) )
# INTERSECT ALL CONTEXT AND REGION FILES
fout="./output_Spo11_intersection.tsv"
echo -e Feature"\t"Group"\t"Num_Spo11"\t"Feature_bp"\t"Spo11_x_Mb > $fout


# First calculate for whole genome (no intersection)
for reg in ${reg_arr[@]};
do
 if [ $reg == "global" ];
 then
  feature=global
  bp=$(awk '{tot+=$2} END {print tot}' pangenome.fai)
 else
  feature=$(basename $reg .bed | sed 's/anno_//')
  bp=$(awk '{len+=($3-$2)} END {print len}' $reg)
 fi
 for SF in ${Group_arr[@]};
 do
  group=$(basename $SF | sed 's/.bed//')
  if [ $reg == "global" ];
  then
   num=$(bedtools merge -i $SF -d -1 | wc -l)
  else
   num=$(bedtools merge -i $SF -d -1 | bedtools intersect -a stdin -b $reg -u | wc -l)
  fi
  num_xBP=$(echo $num | awk -v bp=$bp '{printf "%.2f", ($0/(bp/1000000))}')
  echo -e $feature"\t"$group"\t"$num"\t"$bp"\t"$num_xBP | tr " " "\t" >> $fout
 done
done

###############
## Add Insertion rate and Insertion density scaled to 1 insertion/MB globally
## NB: We need "global" to be the first line of each family, so we use a trick and temporarily change it to "aglobal"
tmp_fout=TMP_megatemp.txt
echo -e $(head -1 $fout)"\t"spo11_rate"\t"spo11_x_MB_global_scaled |
tr " " "\t" > $tmp_fout

tail -n+2 $fout | sed 's/global/aglobal/g' |
sort -k2,2V -k1,1 | sed 's/aglobal/global/g' |
awk 'OFS="\t"{
    if($1=="global"){
        motif_n=$3;
        motif_dens=$5;
        print $0,1,1
    } else {
        rate = (motif_n != 0) ? ($3 / motif_n) : 0;
        density_rate = (motif_dens != 0) ? ($5 / motif_dens) : 0;
        print $0, rate, density_rate
    }
}' >> $tmp_fout
mv $tmp_fout final_spo11_motif_density_table.tsv
