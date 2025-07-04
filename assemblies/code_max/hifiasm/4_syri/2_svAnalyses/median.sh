cat at9900.INV.length.tmp | jq -s 'sort|if length%2==1 then.[length/2|floor]else[.[length/2-1,length/2]]|add/2 end' | sort -n|awk '{a[NR]=$0}END{print(NR%2==1)?a[int(NR/2)+1]:(a[NR/2]+a[NR/2+1])/2}'

