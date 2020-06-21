## <center> Projet RT2 boot réseau </center>
> **Pablo HOUSSE | Théo ANJARD | Solen BELLOUATI | 19 juin 2020**

<div style="text-align:center"><img src="https://i.imgur.com/JUsfL98.png" /></div>

Vous pouvez consulter ce compte rendu à l'adresse suivante (conseillé): 
https://md.iutbeziers.org/s/H1DujdD8I#
Ainsi que notre GitHub : 
https://github.com/solenb/ProjetRT2

***Sommaire***
- [title: Compte rendu projet RT2](#title--compte-rendu-projet-rt2)
- [Projet RT2 boot réseau](#-center--projet-rt2-boot-r-seau---center-)
- [Introduction <a id="intro"></a>](#introduction--a-id--intro----a-)
- [Création automatisée d'une image ISO Linux personnalisée <a id="iso_perso"></a>](#cr-ation-automatis-e-d-une-image-iso-linux-personnalis-e--a-id--iso-perso----a-)
- [Déploiement du serveur PXE <a id="NFS"></a>](#d-ploiement-du-serveur-pxe--a-id--nfs----a-)
  * [Contraintes](#contraintes)
  * [Scripts](#scripts)
    + [initNetBoot.sh:](#initnetbootsh-)
    + [cleanNetBoot.sh](#cleannetbootsh)
- [Serveur et Client NFS](#serveur-et-client-nfs)
  * [Principe](#principe)
  * [Partage nfs accessible par tous les postes du réseau](#partage-nfs-accessible-par-tous-les-postes-du-r-seau)
- [Conclusion / Améliorations possibles<a id="conclusion"></a>](#conclusion---am-liorations-possibles-a-id--conclusion----a-)
- [Bibliographie <a id="bibli"></a>](#bibliographie--a-id--bibli----a-)


## Introduction <a id="intro"></a> 

Le projet que nous allons aborder, découle directement d'un problème récurrent lors du déroulement des Travaux Pratiques à l'IUT. 
Les Travaux pratiques sont un lieu d'expérimentation menant souvent à rendre les machines compliquées à utiliser. Certaines fonctionnalitées se trouvent inutilisables, et cela peut très vite devenir frustrant pour les étudiants devant utiliser la machine.

C'est pour cela que nous avons sélectionné ce sujet, pour pouvoir apporter une aide concrète et une évolution à un système utilisé tous les jours par les étudiant de Réseaux et Télécoms.

Le but final de ce projet est de fournir des machines "jetables" qui seront disponibles par un démarrage en réseau, pour que chaque étudiant puisse disposer d'un même environnement de travail, propre et stable.
L'ajout de fonctionnalitées pouvant améliorer la fuidité de tout ce système, fait partie entière du projet. Notamment le système de sauvegarde de fichier sur le réseau, permettant de ne pas perdre les configurations importantes d'une séance sur l'autre.

## Création automatisée d'une image ISO Linux personnalisée <a id="iso_perso"></a>

Pour cette partie, nous devons mettre en place un système automatisé de création d'images ISO Linux personnalisées. 
Nous avons décidé de choisir d'implémenter un système Linux live, ce qui signifie qu'il fonctionne en entier sur la mémoire vive de la machine hote.
Cette fonctionnalité est essentielle, car elle permet de mettre à disposition une machine propre pour chaque utilisateur. En effet car la mémoire vive est volatile, ce qui signifie qu'à partir du moment où il elle n'est plus alimentée toute donnée est effacée.


>Le live CD installable est un système embarqué utilisable sur CDROM/DVD/USB et installable sur tout support de stockage (clé USB, carte SD, disque dur interne). Il se compose d'un squashfs qui contient l'intégralité du système, un bootloader pour pouvoir démarrer, et accessoirement un installeur (ce sera le cas dans notre tutoriel).
>Le bootloader démarre et lance la décompression du squashfs afin de le rendre utilisable. Dès lors, le CDROM inséré se comporte comme un système d'exploitation classique.
>Live-build est un programme qui permet de créer un live à partir d'un système développé en chroot (le système dans le système chroot = change root).


Et pour ceci, nous avons utilisé l'outils live-build, qui est un ensemble de scripts de haut niveau permettant de créer une image iso live personnalisée. 
C'est un outil compliqué à prendre en main, il faut bien se documenter avant de commencer toute manipulation. 
Le script comprend 3 commandes principales : 
- `lb config` :arrow_right: Cette commande permet d'initialiser dans un répétoire tous les fichier de base permettant de construire par la suite l'image iso.
- `lb clean`  :arrow_right: Cette commande permet de nettoyer un répertoire qui a été initialisé, afin de recommencer la construction d'iso.
- `lb build`  :arrow_right: Cette commande permet de construire une image iso à partir des fichier de configuration présents dans le répertoir initialisé.

Cet outil peut être configuré et personnalisé grâce à de nombreux fichiers. 
Les fichiers que nous avons utilisés permettent de choisir exactement la dernière distribution de Linux (debian | ubuntu), ainsi que l'environnement graphique (7 possibilités).
Les 7 possibilitées sont Mate, Kde, Gnome et Cinnamon pour Ubuntu uniquement, ce qui permet d'adapter le système Live en fonction des préférences de chacun.
On a pu aussi choisir des paquets additionnels, directement intégrés dans l'iso, ainsi que des fichiers placés à la racine du système.

Arborescence du système de fichier développé par la commande `lb build`

![](https://i.imgur.com/FTdxClN.jpg)



Le script que nous avons développé autour de l'outils live-build, permet de remplir les fichiers de configuration, et de tout mettre en place pour faciliter la prise en main.
Il se décompose en plusieurs parties : 

1. La section test de présence du `paquet` live-build
    On va ici tout simplement télécharger sur la machine de l'hôte le paquet `live-build` grâce au gestionnaire de paquet `apt`.
```bash
test=$(lb --version)										    				
if [ -n "$test" ]; then 									    
	echo -e "Live-Build installé en version $(echo $test)\n"				    
else 												    
	echo -e "Live-Build n'est pas installé, l'installation va démarrer \n "		    
	sudo apt install live-build								    
fi			
```
2. La section permettant de selectionner et d'injecter dans les fichiers de configuration le `système d'exploitation` choisi par l'utilisateur.
On va ici faire sélectionner un `système d'exploitation`, tant que l'utilisateur n'aura pas rentré une information correcte il ne sortira pas de la boucle `while`.
```bash
echo -e "L'initialisation de la construction de l'image ISO est en cours, \n
des choix sur la personnalisation de celle-ci vont vous être proposés." 	
echo -e "Veuillez répondre correctement. \n\n"														
echo -e "Quel distribution de Linux voulez-vous ? \t [debian / ubuntu]"											
																			
while [ $debian -ne 1 ] | [ $ubuntu -ne 1 ]; do														
	if [[ $dist == "debian" ]]; then 														
		debian=1																
		break																	
	elif [[ $dist == "ubuntu" ]]; then														
       		ubuntu=1																
		break																	
	else																		
		if [[ $dist != "null" ]];then														
			echo "Veuillez remplir correctement le champ indiqué \n"									
		fi																	
		read dist																
		continue																
	fi																		
done				
```
On va ici aller remplacer dans le fichier de configuration `config`, le système d'exploitation séléctionné au préalable. Grâce à une commande `sed`, on va opérer une substitution (avec la dernière version) de la chaîne de caractère désirée.
```bash
if [ $debian -eq 1 ]; then 								#
	distrib=$( cat config | sed -n '9p' | awk '{print $2}' | sed -e  's/"//g')	#
	sed -i "s/$distrib/buster/g" config						#
else 											#
	distrib=$( cat config | sed -n '9p' | awk '{print $2}' | sed -e  's/"//g')	#
	sed -i "s/$distrib/focal/g" config						#
fi											#
											#
if [ $debian -eq 1 ]; then 								#
	distrib_l=$( cat config | sed -n '6p' | awk '{print $2}' | sed -e  's/"//g')	#
	sed -i "s/$distrib_l/debian/g"	config						#
else 											#
	distrib_l=$( cat config | sed -n '6p' | awk '{print $2}' | sed -e  's/"//g')	#
	sed -i "s/$distrib_l/ubuntu/g"	config						#
fi
```
3. La section permettant l'ajout des metapaquets d'environnement basiques
On va ici remettre à zéro le fichier contenant les `paquets` qui vont être installé dans le système de fichier. Ainsi que procéder à l'ajout des metapaquets d'environnement nécessaire.
```bash
echo -e "Remplissage des metapaquets d'environnement nécessaires\n"		#
										#
base_pak="task-desktop\ntask-french\ntask-french-desktop\nconsole-setup"	#
echo "" > package.list.chroot							#
echo -e $base_pak >> package.list.chroot	
```

4. La section permettant la sélection des bons métapaquets d'environnement spécifiques
On va ici faire sélectionner un métapaquet d'environnement spécifiques, tant que l’utilisateur n’aura pas rentré une information correcte il ne sortira pas de la boucle `while`.
Le fichier où sont stockés les paquets est `package.list.chroot`, dans le dossier `package-lists`.

```bash
if [ $debian -eq 1 ]; then																	
	echo -e "Quel envirronement graphique Debian voulez-vous ? \t [gnome_d / kde_d / mate_d]"								
else																					
	echo -e "Quel envirronement graphique Ubuntu voulez-vous ? \t [gnome_u / kde_u / mate_u / cinnamon]"							
fi																				
																				
while [ $gnome_u -ne 1 ] | [ $kde_u -ne 1 ] | [ $mate_u -ne 1 ] | [ $cinnamon -ne 1 ] | [ $gnome_d -ne 1 ] | [ $kde_d -ne 1 ] | [ $mate_d -ne 1 ]; do		
	if [[ $envi == "gnome_u" ]]; then															 
		gnome_u=1																	
		fin_env="gnome-shell"																			 break 																		 
	elif [[ $envi == "kde_u" ]]; then															
       		kde_u=1																			
		fin_env="plasma-desktop"															
		break																		
	elif [[ $envi == "mate_u" ]]; then															
       		mate_u=1																	
		fin_env="mate-desktop-environment-core"														
		break																		
	elif [[ $envi == "cinnamon" ]]; then															
       		cinnamon=1																	
		fin_env="cinnamon-core"																
		break																		
	elif [[ $envi == "gnome_d" ]]; then															
       		gnome_d=1																	
		fin_env="task-gnome-desktop"															
		break																		
	elif [[ $envi == "kde_d" ]]; then															
       		kde_d=1																		
		fin_env="task-kde-desktop"															
		break																		
	elif [[ $envi == "mate_d" ]]; then															
       		mate_d=1																	
		fin_env="mate-desktop-environment"														
		break																		
	else																			
		if [[ $envi != "null" ]];then															
			echo "Veuillez remplir correctement le champ indiqué \n"										
		fi																		
		read envi																	
		continue																	
	fi																			
done																				
echo -e $fin_env >> package.list.chroot		
```

5. La section permettant la sélection de paquets additionnels
On va ici permettre à l'utilisateur de selectionner des paquets additionnels, qui vont directement être intégrés au système de fichier.

```bash
echo -e "\nVeuillez maintenant ajouter les paquets à inclure dans l'environnement."		
echo -e "Veillez à taper le nom exacte du ou des paquets désirés, séparés par un espace."	
echo -e "Une fois tous les paquets ajoutés, faites un "retour chariot" (entré). \n"		

read -a packets											
packetsLength=$(echo ${#packets[@]})								
arrayp=$(echo ${packets[@]})									
												
for i in `seq 1 $packetsLength`; do								
	echo $arrayp | cut -d" " -f$i >> package.list.chroot					
done					
```

6. La section permettant la sélection de fichiers personnels
On va ici permettre à l'utilisateur de selectionner des fichiers personnels, qui vont directement être intégrés à la racine système de fichier.
Le répertoire où sont stockés est `includes.binary`, dans le dossier.

```bash
echo -e "\nVeuillez maintenant ajouter les fichier à inclure dans l'environnement."			
echo -e "Veillez à taper le chemin exacte du ou des fichiers désirés, séparés par un espace. "		
echo -e "Une fois tous les chemins de fichiers ajoutés, faites un "retour chariot" (entré). \n"		
													
read -a files												
fileLength=$(echo ${#files[@]})											
arrayf=$(echo ${packets[@]})										
												
for i in `seq 1 $fileLength`; do									
	echo $arrayf | cut -d" " -f$i | xargs -i cp {}  includes.binary/ 				
done				
```

7. La section permettant l'initialisation du projet dans un répertoire
On va ici créer et préparer le `répertoire de travail`, allant accueillir le projet. 
```bash
sudo mkdir -p $HOME/live-debian-project							            	
cd $HOME/live-debian-project									    	
echo -e "Le script va construite l'image ISO dans le répertoire $HOME/live-debian-project"	    	
echo -e "Voulez vous construite la base de l'image ? [y-n]"						
read base												
if [ $base == "y" ];then										
	sudo lb config &> /dev/null									
else													
	exit 1											   		
fi		
```

8. La dernière section permettant la construction de l'image ISO
On va ici copier tous les fichiers, qui ont été rempli au fil du script, dans le répertoire de travail. Et lancer ensuite la commande `lb build`, qui va créer l'image iso personnalisée.


```bash
yes | sudo cp -u $path/config $HOME/live-debian-project/auto/										
yes | sudo cp -u $path/package.list.chroot $HOME/live-debian-project/config/package-lists/						
yes | sudo cp -ur $path/includes.binary/* $HOME/live-debian-project/config/includes.binary/						
																	
echo -e "Votre Image Live va être contruite êtes vous sur de vouloir lancer cette opération (cela prend quelques minutes) ? [y-n]"	
read build_l																
if [ $build_l == "y" ]; then 														
	sudo lb build															
else 																	
	echo -e "Vous pourrez la commande de construction tout seul grâce à [lb build]"							
fi			
```
Au final nous obtenons une image iso de Linux live bootable nommée `live-image-amd64.hybrid.iso`


## Déploiement du serveur PXE <a id="NFS"></a>

Qu'est ce que le PXE:
Le Pre-boot eXecution Environment ou PXE est un ensemble de processus permettant à une machine de démarrer depuis le réseau. Pour y parvenir, elle récupère une image sur un serveur et la charge dans sa mémoire vive.
Plusieurs étapes sont nécéssaires pour arriver à ce résultat:
- A l'allumage, la machine va démarrer sur la carte réseau et cherche à obtenir une adresse IP. Elle va donc diffuser sur le réseau, une trame DHCP Discover dans le but de joindre un serveur DHCP.
- Le serveur recevant la requête va proposer une adresse ainsi qu'une valeur dhcp-boot. Dans notre cas : 
```dhcp-boot=/var/tftpboot/pxelinux.0```
Cette valeur indique à la machine qu'elle doit démarrer en utilisant le fichier donné. Le serveur fournis aussi le protocol de téléchargement ainsi l'emplacement du fichier. Grâce à la valeur ```tftp-root=/var/tftpboot/``` .
- La machine télécharge le fichier et l'éxécute. Celui-ci est un chargeur de démarrage, il permet de récupérer la configuration de PXE depuis le serveur d'ou il a été téléchargé.
- La machine affiche à l'utilisateur un menu qu'elle a téléchargé. Celui-ci propose différente option de démarrage il peut s'agir d'une image ISO ou d'un fichier initrd permettant d'éxecuter une image live.

Le but de ce projet est d'automatiser le déploiement de cette technologie pour qu'elle soit utilisable dans les salles de travaux pratique de l'IUT.

### Contraintes
Nous relevons deux contraintes principales pour le déploiement du PXE. 
Premièrement, nous n'avons pas accés à des serveurs dédié à chaque salle. Il est donc impossible de prévoir une configuration fixe.
Deuxièmement, le processus doit être rapide afin de ne pas empiétier sur le déroulement des travaux pratiques.

La première contrainte implique d'utiliser l'ordinateur du professeur en charge du TP comme serveur PXE. Il faudra donc aussi proposer une solution pour "nettoyer" la machine à la fin du cours.

Pour cela, nous utiliserons deux script bash, l'un permettant de mettre en place le PXE et l'autre de remettre la machine dans l'état initial. 

### Scripts 
#### initNetBoot.sh:
Ce script a pour but d'installer et de configurer le serveur Pxe. 
Pour faire cela, il y a plusieurs étapes:
- La configuration de l'interface réseau
```bash=
if [ -z $(ifconfig $interface | sed -n '1p' | grep -o "UP") ];then	
	if [[ $verb = "true" ]];then
		echo "The interface is down, setting it up..."
	fi
	ip link set up dev $interface
fi
srv_ip=$(ifconfig $interface | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sed -n 1p)
if ! [[ -z $srv_ip ]];then
	if [[ $verb = "true" ]];then
		echo "Flushing ip address on $interface"
	fi
	ip addr flush dev $interface;
fi
if [[ $verb = "true" ]];then
	echo "Adding ip address 192.168.55.254 on $interface"
fi
ip addr add 192.168.55.254/24 dev $interface
```
Cette partie vérifie que l'interface indiquée est allumée (Si non, l'allume), vérifie qu'elle n'a pas l'IP (Si oui, la supprime) et ajoute l'adresse **192.168.55.168/24**
- L'installation des paquets nécéssaires
```bash=
lib="$(ls /var/lib/)"
if ! [ -z "$(echo $lib | grep -o 'apt')" ];then
	install_command="apt install -y ""$(if [ -z $verb ];then echo '-q ';fi)""dnsmasq pxelinux syslinux-common nfs-kernel-server"
elif ! [ -z "$(echo $lib | grep -o 'pacman')" ];then
	install_command="pacman -Sy $(if [ -z $verb ];then echo '-q ';fi)--noconfirm dnsmasq pxelinux syslinux nfs-utils"
elif ! [ -z "$(echo $lib | grep -o 'yum')" ];then
	install_command="yum install -y $(if [ -z $verb ];then echo '-q ';fi)dnsmasq pxelinux syslinux nfs-utils"
else
	echo "Warning: Your package manager is not detected, make sure you have install dnsmasq, pxelinux and syslinux (or syslinux-common) packages"
fi
if [ -z $no_install ];then
	if [[ $verb = "true" ]];then
		echo -e "\n## Installing needed packages: $install_command ##"
	else
		install_command="$install_command"" > /dev/null"
	fi
	eval $install_command
	echo -e "## Installation finished ##\n"#
fi
```
Ici, on commence par vérifier la gestionnaire de paquet de la machine puis on installe les paquets requis. Dnsmasq sera notre serveur DHCP et TFTP, pxelinux et syslinux contiennent des librairies dont nous aurons besoin et le paquet nfs sera notre serveur NFS.
- Copie des librairies nécéssaire au démarrage, dans le répertoire TFTP
```bash=
if [[ $verb = "true" ]];then
	echo "Loading boot menu in /var/tftpboot/pxelinux.cfg"
fi
if [ -z $live ];then
	sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')pxe_installation.menu /var/tftpboot/pxelinux.cfg/default
else
	sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')pxe_live.menu /var/tftpboot/pxelinux.cfg/default
fi
if [[ $verb = "true" ]];then
	echo "Copying needed library in tftp folder..."
fi
if [ -z $(ls /var/tftpboot/ | grep pxelinux.0) ];then
	sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')lib/* /var/tftpboot/
fi
```
On charge d'abord le menu PXE dans **/var/tftpboot/pxelinux.cfg/**, soit pxe_installation.menu, soit pxe_live.menu en fonction de l'option donné au script.
On copie ensuite les librairies nécéssaires au PXE dans **/var/tftpboot/** .

- Configuration du serveur NFS
Le NFS est nécéssaire uniquement en cas de boot sur une image live. Dans ce cas, on ajoute la ligne suivante dans le fichier **/etc/exports**:
```/var/tftpboot/nfs 192.168.55.0/24(sync,no_root_squash,no_subtree_check,ro)```
On partage donc le dossier **/var/tftpboot/nfs** à l'ensemble du réseau en mode read-only (cf partie NFS pour plus d'informations sur les options)
- Montage de l'iso et copie des fichiers dans le NFS
Si l'image diffusée n'est pas live, cette partie est inutile car l'on copie simplement le fichier dans le répertoire TFTP.
Dans le cas contraire, on monte l'image indiquée dans l'option du script et on copie son contenu dans le répertoire NFS:
```bash=
if [[ $verb = "true" ]];then
		echo "# Mounting iso #"
		echo -e "\tCreating /mnt/netiso/ folder"
	fi
	mkdir -p /mnt/netiso/
	if [[ $verb = "true" ]];then
		echo -e "\tMounting iso on /mnt/netiso"
	fi
	mount -o loop $image /mnt/netiso/ > /dev/null
	if [[ $verb = "true" ]];then
		echo -e "\tCopying mounted files in nfs folder"
	fi
	cp -r /mnt/netiso/* /var/tftpboot/nfs/
	if [[ $verb = "true" ]];then
		echo -e "\tUnmounting image"
		echo "################"
	fi
	umount /mnt/netiso

```
- Configuration de dnsmasq: DHCP, TFTP
```bash=
if [[ $verb = "true" ]];then
	echo "Configuring dnsmasq..."
fi
cat $(echo $0 | sed 's/initNetBoot.sh//g')dnsmasq.conf | sed "s/%NIC%/$interface/g" > /etc/dnsmasq.conf
if [[ $verb = "true" ]];then
	echo "Restarting dnsmasq..."
fi
systemctl restart dnsmasq.service
``` 
Dans cette partie du script, on copie le fichier **dns.conf** de notre repository dans **/etc/** en remplacant %NIC% par l'interface réseau.

**dns.conf:**
```bash=
# Cette variable indique le port d'écoute du DNS, on la mettant à 0, on désactive implicitement le DNS.
port=0
# Interface d'écoute du serveur, on remplace %NIC% par celle de l'utilisateur
interface=%NIC%
# L'adresse IP du serveur
listen-address=192.168.55.254
listen-address=127.0.0.1
# On active les log du serveur DHCP
log-dhcp
# On définis içi la plage d'adresse que le serveur a à disposition
dhcp-range=192.168.55.1,192.168.55.253
# Variable transmise avec le DHCP OFFER contenant le fichier de boot
dhcp-boot=/var/tftpboot/pxelinux.0
# On active le serveur TFTP
enable-tftp
# Indique au client le protocole de téléchargement ainsi que le répertoire TFTP
tftp-root=/var/tftpboot/
```
- Activation du routage des paquets
Pour que les machine client aient accès à internet, il faut que le serveur redirige leurs paquets.
```
if [[ $verb = "true" ]];then
	echo "Activating ip forwarding..."
fi
echo 1 > /proc/sys/net/ipv4/ip_forward
```
- Création d'une règle iptables laissant passer les trames UDP sur le port 69
```
if [[ $verb = "true" ]];then
	echo "iptables: Accept UDP port 69"
fi
iptables -A INPUT -p udp -m udp --dport 69 -j ACCEPT
```
#### cleanNetBoot.sh
Ce script permet de remettre la machine/serveur dans son état initial. Il permet de supprimer les paquets, de réinitialiser l'interface réseau, supprimer le contenu du répertoire TFTP et supprimer la règle iptables.

## Serveur et Client NFS

Il nous faut désormer créer un lien entre le professeur et les étudiants. Cela permettra de sauvegarder des documents, des fichiers de configuration sur la machine physique de l'enseignant. Car pour rappel à la fin de chaque séance les postes sont remis à 0.

> Définition

Network File System (NFS), ou système de fichiers en réseau, est une application client/serveur qui permet à un utilisateur de consulter, de stocker et de mettre à jour des fichiers sur un ordinateur distant, comme s'ils étaient sur son propre ordinateur.
![](https://i.imgur.com/YR152SP.jpg)

Il fait partie de la couche application du modèle OSI et utilise le protocole RPC.
Il existe plusieurs versions de ce protocol.
Nous avons NFSv1 et NFSv2 (définie dans la RFC 1094 , mars 1989) qui permettent un partage qui repose sur UDP et donc non sécurisé.
Avec la version 3 ( RFC 1813 , juin 1995)  :
-- la taille maximum de fichier n'est plus limitée à 2Go.
-- La taille des données transférées n'est plus limitée à 8Ko.
-- Il est possible d'utiliser le protocole TCP au niveau transport.

NFSv4 apporte quand à elle beaucoup de nouveauté niveau sécurité.

Les stations de travail utilisent moins d'espace disque en local parce que les données utilisées en commun peuvent être stockées sur une seule machine tout en restant accessibles aux autres machines sur le réseau.

Les utilisateurs n'ont pas besoin d'avoir un répertoire personnel sur chaque machine du réseau. Les répertoires personnels pourront se trouver sur le serveur NFS et seront disponibles par l'intermédiaire du réseau.

### Principe

Afin de réaliser le montage nfs nous avons édité deux scripts, nfs-server.sh et nfs-client.sh. Un s'exécutant sur le serveur et un autre sur le client.
Le montage nfs est en plusieurs parties. Nous commencons par créer un répertoire accessible par tout les étudiants, ensuite chaque étudiant crée un point de montage vers le répertoire en question dans le but d'y déposer un fichier qui servira à lui créer un répertoire accessible uniquement par lui.
### Partage nfs accessible par tous les postes du réseau 
> Sur le serveur

On rappelle que nfs-kernel-server est installé sur la machine de l'enseignant.
On lance le script sur le serveur, il se lance de la façon suivant: ./nfs-server.sh -option. 
Il y a tout 4 options, -e,-s, -c, -h.
L'option -e va dans un premier temps, nous permettre de créer un répertoire partagé accessible par tout les postes clients de la salle.
```/var/nfs_server/users```. 

```bash=1
if [ -n $etu ] && [ -z $secure ] && [ -z $clean ];then		
	mkdir -p /var/nfs_server/users 2> /dev/null
	if [[ $(cat /etc/exports | grep "nfs_server/users 192.168.1.0") == "" ]];then
echo "/var/nfs_server/users 192.168.55.0/24(sync,no_root_squash,no_subtree_check,rw)" >> /etc/exports
	fi
	systemctl restart nfs-server
	exit 0
fi
```
*/etc/exports* est le fichier de configuration des partages NFS, on y indique le dossier à partager, à qui ont le partage et ce que l'on lui aurorise à faire.
Exemple si dessous : 

```/var/nfs_server/users 192.168.55.0/24``` :arrow_right: le chemin du répertoire partagé accessible par tout le réseau.
```rw``` :arrow_right: La lecture et l'écriture sont autorisées dans ce dossier.
```sync``` :arrow_right: ne répond que lorsque les changements sont executés.
```no_root_squash``` :arrow_right: options pour les postes de travail sans disque qui requièrent un accès root complet sur l'ensemble du système de fichiers.
```no_subtree_check``` :arrow_right: permet uniquement l'accès au sous répertoire cité pour que seul l'administrateur ait le droit d'accés sur ces autres fichiers.

Cette première action permet donc de créer un répertoire partagé disponible pour tous. Le but étant que chaque étudiants envoie sur ce répertoire partagé un fichier qui porte son nom et qui contient son ip. 
> Sur le client

Pour éxécuter le script nfs-client.sh, il nous faut renseigner une option et un login. Le login étant le nom de l'utilisateur.
Afin de pouvoir utiliser nfs sur le client il nous faut installer ```nfs-common```. Le répertoire à monter est ```mnt/nfs_users``` pour ce faire on execute ```mount -t nfs 192.168.55.254:/var/nfs_server/users/```
```-t nfs``` précise le type de montage à savoir nfs.
```192.168.55.254:/var/nfs_server/users/ /mnt/nfs_users/``` :arrow_right: ip et le répertoire du serveur/ le point de montage sur le client.
On récupère ensuite l'ip de la machine client que l'on ajoute dans le fichier qui porte le nom de l'utilisateur: **/mnt/nfs_users/[login]** .
On stock ensuite le login dans un fichier **/tmp/nfs_client.tmp** afin d'éviter à l'utilisateur de renseigner une nouvelle fois son login.
```bash=1
if [ -n $login ] && [ -z $private_dir ] && [ -z $clear ];then
	apt-get install -y nfs-common
	mkdir /mnt/nfs_users/ 2> /dev/null
	echo $login
	mount -t nfs 192.168.55.254:/var/nfs_server/users/ /mnt/nfs_users/
	echo $(ip a | grep -o "192.168.55.*/24" | cut -d "/" -f1) > /mnt/nfs_users/$login
	echo $login > /tmp/nfs_client.tmp
```
Grâce à cela le serveur a accès à l'ip et le nom de chaque étudiant via le dossier ```/var/nfs_server/users/```. 
> Sur le serveur

Nous pouvons maintenant relancer le script serveur mais cette fois ci avec la deuxième option -s. Elle permet de récupérer chaque fichier que les étudiants ont laissé dans /var/nfs_server/users pour créer un répertoire personnel à chacun. Ce dossier se trouve dans ```/var/nfs_server/auth/[USER]/```. On ajoute cette ligne ```/var/nfs_server/auth/[USER] [USER_IP]/24(sync,no_root_squash,no_subtree_check,rw)``` à ```/etc/exports``` puis on relance le server.

```bash=1
if [ -n $secure ] && [ -z $etu ] && [ -z $clean ];then
	mkdir /var/nfs_server/auth/ 2> /dev/null
	for user in $(ls /var/nfs_server/users);do
		mkdir /var/nfs_server/auth/$user 2> /dev/null
		echo "/var/nfs_server/auth/$user $(cat /var/nfs_server/users/$user)/24(sync,no_root_squash,no_subtree_check,rw)" >> /etc/exports
	done
	systemctl restart nfs-server
	exit 0
fi
```
La dernière option du serveur -c permet d'arrêter le serveur, de supprimer le contenu de **/var/nfs_server/users/** et réinitialiser la configuration des montages NFS. On garde cependant le dossier **/var/nfs_server/auth** car il contient les données des utilisateurs.
```bash=1
if [ -n $clean ] && [ -z $etu ] && [ -z $secure ];then
	systemctl stop nfs-server
	echo "" > /etc/exports
	rm -rf /var/nfs_server/users/*
	exit 0
fi
```
Enfin sur le client, nous montons sur ```/mtn/save``` qui correspond à ```var/nfs_server/auth/nom_de_l'utilisateur/``` sur le serveur.

Si le montage se passe mal pour x raisons, l'option -p permet de démonter les partitions pour avoir un client propre.
```bash=1
elif [ -n $private_dir ] && [ -z $login ] && [ -z $clear ];then
	mkdir /mnt/save 2> /dev/null
	umount /mnt/nfs_users
	mount -t nfs 192.168.55.254:/var/nfs_server/auth/$(cat /tmp/nfs_client.tmp) /mnt/save/
```
## Conclusion / Améliorations possibles<a id="conclusion"></a>

Nous avons vraiment aprécié réaliser ce projet,  il a été très instructif dans les domaines de l'administration système et réseaux ainsi que du scripting.  
Nous pensons que certains parties peuvent être améliorés, nous avons notament pensé à faire une interface graphique. Celle-ci permettrait de rassembler la création d'iso et le déploiement du serveur PXE et NFS. Nous pourrions aussi rendre la création de l'iso plus rapide et possible avec plus de distributions. L'utilisation de Kerberos permettrait aussi de chiffrer les communications.


## Bibliographie <a id="bibli"></a>
Live-build: 
https://arpinux.developpez.com/construire-un-live-debian/

https://manpages.debian.org/testing/live-build/lb_config.1.fr.html

https://burogu.makotoworkshop.org/index.php?post/2016/08/09/livebuild

PXE:
https://lea-linux.org/documentations/Installer_Debian_par_un_boot_r%C3%A9seau

https://wiki.syslinux.org/wiki/index.php?title=PXELINUX

https://rocketboards.org/foswiki/Documentation/BuildingInitramfsForSimpleNetworkBoot

https://linux.developpez.com/formation_debian/nfs.html

https://debian-handbook.info/browse/fr-FR/stable/sect.nfs-file-server.html
NFS: 
https://www.netapp.com/fr/communities/tech-ontap/nfsv4-0508-fr.aspx

https://help.ubuntu.com/community/NFSv4Howto

https://fr.wikipedia.org/wiki/Network_File_System
