#!/bin/bash
##########################################################################################
#	Customiso.sh allows, as its name suggests, to modify and customize iso easily  #
##########################################################################################
usage(){
	echo -e "Customiso.sh allows, as its name suggests, to modify and customize iso easily\nYou can enter a iso file as first argument"
}
pathiso=$(echo $0 | sed 's/customiso.sh//g')"newiso"
if [[ $1 = *.iso ]] 2> /dev/null && [ -e $1 ] 2> /dev/null;then
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
mkdir /mnt/tempiso || fail=1
echo $fail
if [ $fail -eq 1 ] 2> /dev/null;then
	echo "Vous ne disposez pas des droits suffisants" 
	exit 1	
fi
mkdir $pathiso
mount -o loop $image /mnt/tempiso
cp -r /mnt/tempiso/* $pathiso
umount /mnt/tempiso
rm -rf /mnt/tempiso
