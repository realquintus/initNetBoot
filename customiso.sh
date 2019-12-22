#!/bin/bash

$pathiso=$0"/newiso"
if [[ $1 = *.iso ]] && [ -e $1 ];then
	image=$1
else
	echo "Entrez une imagei iso à personnaliser:"
	read image
	while true;do
		if [[ $image = *.iso ]] && [ -e $image ];then
			break
		fi
		echo "Entrez une image iso valide:"
		read image
	done
fi
sudo mkdir /mnt/tempiso
mkdir $pathiso
mount -o loop $image /mnt/tempiso
cp /mnt/tempiso/* $pathiso
unmount /mnt/tempiso
