for i in $(ls at*.syri.out); do
	NAME=$(echo $i | awk -F'.' '{print $1}')
	echo "processing" $NAME
	for line in $(cat $i | awk '{print $11}' | sort | uniq ); do
		echo $NAME > $NAME.$line.length
		echo $line "length calculated"
		grep -w "$line" $i | awk '{print ($8-$7)}' | sed 's/-//g' >> $NAME.$line.length
	done
done


#for i in $(ls at*.sv.txt); do
#	NAME=$(echo $i | awk -F'.' '{print $1}')
#	for line in $(cat $i | awk '$1 !~/^#/ {print $1}' | sort | uniq); do
#		grep "$line" $i | awk '{print ($5-$4)}' | sed 's/-//g' > $NAME.$line.txt
#	done
#done
