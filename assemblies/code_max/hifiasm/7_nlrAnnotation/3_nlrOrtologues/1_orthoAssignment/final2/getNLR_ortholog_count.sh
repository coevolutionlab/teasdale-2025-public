
#!/bin/bash

for i in $(ls *.uniq.tmp); do
	TYPE=$(echo $i | awk -F'.uniq.tmp' '{print $1}')
	for line in $(cat $i); do
		NAME=$(echo $line | awk -F';' '{print $2}' | awk -F'_' '{print $2}' | awk -F'.' '{print $1}')
		echo $NAME
		echo $line > $TYPE.$NAME.list
		for file in $(ls $TYPE.$NAME.list); do
			cat $file | sed 's/;/\n/g' | awk -F'_' '{print $1}' | awk 'NF==1' | sort | uniq -c | awk -v pat="$NAME" '{print $1, $2, pat}' > $TYPE.$NAME.list.tmp
		done
	done
	cat $TYPE.*.list.tmp | sed 's/Araport/TAIR10/g' | sed 's/at/AT/g' | awk '$2 !~/^arenosa/' > $TYPE.4R
	rm $TYPE.*.list.tmp
	rm $TYPE.*.list
done


