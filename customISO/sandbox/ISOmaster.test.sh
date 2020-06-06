### Test de présence du paquet live-build
#test=$(lb --version)
#if [ -n "$test" ]; then 
	#echo -e "Live-Build installé en version $(echo $test) \n"
#else 
	#echo -e "Live-Build n'est pas installé, l'installation va démarrer \n "
	#sudo apt install live-build
#fi

#sudo mkdir $HOME/live-debian
#sudo cd $HOME/live-debian
#echo -e "Le script va construite l'image ISO dans le répertoire $(echo$(pwd))"
#sudo lb config
ubuntu="0"
debian="0"
echo -e "L'initialisation de la construction de l'image ISO est en cours, \n des choix sur la personnalisation de celle-ci vont vous être proposés. \n 
Veuillez répondre correctement. "
echo -e "Quel distribution de Linux ? \t [debian - ubuntu]"
read dist
while [ $dist != "debian" ] | [ $dist != "ubuntu" ]; do
	if [[ $dist == "debian" ]]; then 
		debian="1"
		break
	elif [[echo $dist == "ubuntu" ]]; then
       		ubuntu="1"
		break	
	else
		echo "Veuillez remplir correctement le champ indiqué"
		read dist
		continue
	fi
done
echo -e "debian : $debian"
echo -e "ubuntu : $ubuntu"
