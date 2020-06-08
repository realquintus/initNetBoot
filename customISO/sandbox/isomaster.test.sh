###################  Test de présence du paquet live-build  #########################################
test=$(lb --version)
if [ -n "$test" ]; then 
	echo -e "Live-Build installé en version $(echo $test)"
else 
	echo -e "Live-Build n'est pas installé, l'installation va démarrer \n "
	sudo apt install live-build
fi
#####################################################################################################


###################  Création du répertoire de travail  ############################################# 
#sudo mkdir -p $HOME/live-debian
#cd $HOME/live-debian
echo -e "Le script va construite l'image ISO dans le répertoire $HOME/live-debian"
#sudo lb config

#####################################################################################################
ubuntu=0
debian=0
dist="null"
echo -e "L'initialisation de la construction de l'image ISO est en cours, \n des choix sur la personnalisation de celle-ci vont vous être proposés. \n 
Veuillez répondre correctement. "
echo -e "Quel distribution de Linux voulez-vous ? \t [debian - ubuntu]"

while [ $debian -ne 1 ] | [ $ubuntu -ne 1 ]; do
	if [[ $dist == "debian" ]]; then 
		debian=1
		break
	elif [[ $dist == "ubuntu" ]]; then
       		ubuntu=1
		break	
	else
		if [[ $dist != "null" ]];then
			echo "Veuillez remplir correctement le champ indiqué"
		fi
		read dist
		continue
	fi
done

#### Ubuntu environment metapackages ####
gnome_u=0				#
kde_u=0					#
mate_u=0				#
cinna=0					#
#########################################

#### Debian environment metapackages ####
gnome_d=0				#
kde_d=0					#
mate_d=0				#
#########################################

envi="null"
if [ $debian -eq 1 ]; then
	echo -e "Quel envirronement graphique Debian voulez-vous ? \t [gnome - kde - mate]"
else
	echo -e "Quel envirronement graphique Ubuntu voulez-vous ? \t [gnome - kde - mate - cinnamon]"
fi

while [ $gnome_u -ne 1 ] | [ $kde_u -ne 1 ] | [ $mate_u -ne 1 ] | [ $cinna -ne 1 ] | [ $gnome_d -ne 1 ] | [ $kde_d -ne 1 ] | [ $mate_d -ne 1 ]; do
	if [[ $envi == "gnome_u" ]]; then 
		gnome_u=1
		break
	elif [[ $envi == "kde_u" ]]; then
       		kde_u=1
		break		
	elif [[ $envi == "mate_u" ]]; then
       		mate_u=1
		break			
	elif [[ $envi == "cinna" ]]; then
       		cinna=1
		break	
	elif [[ $envi == "gnome_d" ]]; then
       		gnome_d=1
		break	
	elif [[ $envi == "kde_d" ]]; then
       		kde_d=1
		break	
	elif [[ $envi == "mate_d" ]]; then
       		mate_d=1
		break	
	else
		if [[ $envi != "null" ]];then
			echo "Veuillez remplir correctement le champ indiqué"
		fi
		read dist
		continue
	fi
done

