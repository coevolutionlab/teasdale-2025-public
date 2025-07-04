#touch a b c d
f=(*fasta)
for ((i = 0; i < ${#f[@]}; i++)); do 
      for ((j = i + 1; j < ${#f[@]}; j++)); do 
          echo "${f[i]} - ${f[j]}"; 
      done;
done 
