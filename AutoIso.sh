#!/bin/sh

echo "Bienvenue dans l'interface de création d'image iso live personnalisées, AutoIso"
set -e
commande="lb config noauto "
##	Architecture	##
while [ $bits -ne 32 ] || [ $bits -ne 64 ];do
	echo -e "Voulez-vous utiliser une image 32 ou 64 bits, 64 par défaut ? (32/64)\n"
	read bits
	${bits:-64}
done
if [ $bits -eq 32 ];then
	commande=$commande"--architecture i386 --linux-flavours \"586 686-pae\" "
elif [ $bits -eq 64 ];then
	commande=$commande"--architecture amd64"	
fi;
##########################
##	Image Linux	##
echo -e "Quel iso Linux voulez-vous utiliser?\n"
while [[ $image == *.iso ]];do
	echo "Entrez une image au format .iso :" 
	read image
done;
	commande=$commande"--linux"
##########################
#lb config noauto \
#    --architectures i386 \
#    --linux-flavours "586 686-pae" \
#    --linux-packages $image \
#    --ignore-system-defaults \
#    --bootappend-live "boot=live components autologin username=test"
#    "${@}"
