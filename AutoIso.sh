#!/bin/bash

echo "Bienvenue dans l'interface de personalisation d'image live Debian, AutoDebIso"
set -e
commande="lb config noauto "
##	Architecture	##
echo -e "Voulez-vous utiliser une image 32 ou 64 bits, 64 par défaut ? (32/64)"
read bits
bits=${bits:-64}
while true;do
	if [ $bits -eq 32 ] 2> /dev/null || [ $bits -eq 64 ] 2> /dev/null;then
		break
	fi
	echo "Entrez 32 ou 64:"
	read bits
done
if [ $bits -eq 32 ];then
	commande=$commande"--architecture i386 --linux-flavours \"586 686-pae\" "
elif [ $bits -eq 64 ];then
	commande=$commande"--architecture amd64 "	
fi;
##########################
##	Image Linux	##
echo -e "Quel version de Debian voulez-vous utiliser voulez-vous utiliser? (A appeler par son petit nom)"
read version
version=${version:-"buster"}
while true;do
	if [[ -n $(echo "buster,stretch,jessie,wheezy,squeeze,lenny,etch" | grep -io $version ) ]] 2> /dev/null;then
		commande=$commande"--distribution $version "
		break
	fi
	echo "Entrez une version valide de Debian (Buster, Stretch, Jessie, Wheezy, Squeeze, Lenny ou Etch):" 
	read image
done;
##########################
commande=$commande"--linux-packages \"linux-image\" --ignore-system-defaults"
echo "Entrez le nom de l'utilisateur (test par défault):"
read username
username=${username:-"test"}
commande=$commande"bootappend-live \"boot=live components autologin username=$username lang=fr_FR.UTF-8 locales=fr_FR.UTF-8 keyboard-layouts=fr keyboard-model=pc105 timezone=Europe/Paris utc=yes toram swap=true\""
echo $commande
##########################
#lb config noauto \
#    --architectures i386 \
#    --linux-flavours "586 686-pae" \
#    --linux-packages $image \
#    --ignore-system-defaults \
#    --bootappend-live "boot=live components autologin username=test"
#    "${@}"
