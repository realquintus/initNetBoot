#! /bin/bash
read -a tableau
long=$(echo ${#tableau[@]})
array=$(echo ${tableau[@]})
echo $array
for i in `seq 1 $long`; do
	echo $array | cut -d" " -f$i >> test.txt

done
