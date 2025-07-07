
for superfam in  DNA LINE SINE Helitron LTR ; do

	for fam in ${superfam}/*.consensus.fa ; do
	 		name=$(basename $fam .consensus.fa) ;
	 		sed -i "s/EMBOSS_001/${name}/" $fam ;
	done
done
