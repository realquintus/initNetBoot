# Déploiement d'un serveur sur Raspberry Pi 4
> [name=Pablo HOUSSE]
## Sommaire :

[TOC]

* **I- Cahier des charges** 
* **II- Etude et choix entre différentes solutions**
* **III- Déploiement**

## I- Cahier des charges
**1) Introduction et présentation du projet**

**Présentation:** 
Ce projet consiste en la mise en place d'un serveur proposant plusieurs services sur Raspberry Pi 4 ainsi que la rédaction d'un article expliquant les choix réalisés entre les différentes technologies et expliquant comment le reproduire (à la manière d'un tutoriel).

**Pourquoi choisir une Raspberry pi 4 ?**
Avant la sortie de cette nouvelle génération, les performances des raspberry étaient bien trop faibles pour permettre le déploiement d'un tel serveur.
Pour mettre en place un serveur personnel à moindre coût, il fallait souvent utiliser de vieilles machines. Celles-ci embarquaient des technologies obsolètes, posant ainsi des problèmes de compatibilité avec les nouveaux logiciels.
De plus il fallait supporter des contraintes importantes: Le bruit, l'emcombrement et la consommation électrique.
Tout ceci rendant une telle installation difficile à mettre en place sans un espace dédié.

La Raspberry pi 4 4Go ne pose aucun de ces problèmes car elle allie la discrétion et l'embarquabilité propre aux Raspberry tout en proposant des performances dignes d'une machine de bureautique.
Ses 4 Go de mémoire vive lui permettent l'éxécution de plusieurs programmes en simultané et son processeur à 4 coeurs cadencés à 1.5 GHz lui permet une efficacité bien plus importante que ses prédécesseurs.

**Objectif:**
L'objectif de ce projet est de démontrer qu'il est possible d'utiliser une Raspberry comme serveur personnel avec tous les avantages que cela apporte: Suppression des frais d'hébergement, accès aux données en local, accès à la machine physique. 
Le tout pour un prix réduit et sans les inconvénients d'une vieille machine.


**2) Besoins et contraintes**

**Besoins fonctionnels:**
Les services que le système doit proposer sont les suivants:
* Supervisions du système (Utilisation du processeur, de la mémoire vive, stockage etc...), du réseau local (Contrôle des flux, des débits ...etc) ainsi que des applications.
* Envoi et réception de mails.
* Publication d'articles techniques.
* Stockage et gestion de plusieurs versions de code.
* Accés au réseau local depuis l'extérieur.
* Affichage d'un hub des services proposés.

**Contraintes:** 
* La contrainte majeure du projet est la puissance de la Raspberry Pi qui est relativement limitée pour une utilisation en tant que serveur.
* L'interface utilisateur doit être intuitive et fluide.
* Le processeur de la Raspberry étant d'une architecture ARM, il sera plus difficile de trouver des programmes et des images complilées pour celui-ci.

**3) Résultat attendu:**
Un système stable et supervisé proposant:
* Un service de mails.
* Un logiciel de gestion de versions de code.
* Un portfolio en anglais/francais.
* Un blog.
* Un VPN.
* Un DNS.

Ainsi que la rédaction d'un article précis permettant de reproduire le système et de comprendre les choix réalisés.

## II- Etude et choix entre différentes solutions

Le critère principal que nous allons utiliser pour choisir entre les différentes solutions est la demande en ressources de chaque technologie.
Il nous faut faire ces choix dans l'optique d'assurer la disponilibilité de tous nos besoins fonctionnels avec les performances limitées de notre machine.

### **OS**
Le système d'exploitation ou OS (Operating System) est un ensemble d'outils permettant de gérer l'utilisation des ressources de l'ordinateur, il est donc fondamental.

Sur le site officiel de Raspberry on relève que les 3 OS suivants sont reconnus officiellement:
* **Raspbian Lite**
**Utilisation de la RAM: 450MB**
Basé sur la distribution Debian, il à été conçu et optimisé pour les processeurs ARM de Raspberry Pi.
Un de ses gros points forts est sa communauté très importante et active. Dans le monde de l'open-source, c'est indispensable car cela permet des mises à jour très régulières et l'accès facile aux solutions aux verrous technologiques.
C'est la référence sur Raspberry.
Cette version Lite exclus l'interface graphique et tous les programmes qui ne sont pas absolument nécéssaires à son fonctionnement.
* **Ubuntu Mate**
**Utilisation de la RAM: 575MB**
Egalement basé sur Debian, il est plus lourd et surtout destiné à un usage comme ordinateur de bureau. Ce qui en fais un OS peu utile dans notre cas.
Il reste un bon système d'exploitation.
* **Windows 10 IoT Core**
**Utilisation de la RAM: environ 350MB**
Bien que cet OS soit basé sur Windows, il se révèle très utile pour les développeurs. Il permet de concevoir des programmes et applications PC via Windows Azure et Visual Studio et de les exécuter directement sur la Raspberry Pi. C'est aussi un des OS les plus légers.
Cependant, celui-ci ne correspond pas à nos besoins car il reste basé sur windows. Il est donc difficile de trouver des projets open-source permettant de l'exploiter.

En réalité, il existe de nombreux autres OS mais ceux-ci sont souvent destinés à des usages spécifiques (Kali Linux pour la sécurité, RetroPie pour le retro gaming ...etc). J'ai décidé de comparer ceux-ci car ils sont assez généralistes tout en représentant trois différentes manières de penser un OS.
Je sais que Pidora aurait pu aussi être un excellent concurrent mais étant basé sur Fedora, de nombreuses commandes sont différentes et je n'y suis pas habitué.

Si on compare les trois OS proposés, **Raspbian** se démarque rapidement. En effet, on peux exclure Windows 10 IoT Core car, comme évoqué, plus haut, il n'est pas vraiment "open-source friendly".
Ensuite, Ubuntu Mate est pensé pour être utilisé comme ordinateur de bureau. Il embarque donc un ensemble de programmes qui seront inutiles et qui ralentiront notre machine.

Raspbian Lite semble donc être l'OS le plus adapté à l'utilisation que nous allons en faire.
### **Outil de conteneurisation**

La conteneurisation permet de séparer nos services et offre plusieurs avantages: 
* Elle permet de rediriger plus facilement les paquets à destination des différents services. Chaque conteneur étant assigné à un service, on peux mettre en place l'équivalent d'un routeur physique.
* C'est beaucoup plus sécurisé. En effet, si un service est compromis, il est beaucoup plus difficile pour un bug ou un attaquant, d'atteindre les autres services ou même le système de la machine physique.
* Les mises à jour sont simplifiées. Le conteneur étant rapide à déployer, les mises à jour sont plus simples et ne risquent pas de compromettre la machine physique. Il s'agit souvent de redémarrer le conteneur en changeant le numéro de version.
* C'est beaucoup plus facile à automatiser qu'une machine virtuelle: Le lancement s'éffectuant par une simple commande. On peux donc prévoir un PRA (Plan de reprise d'activité) simplement, en cas d'arrêt de la machine.
</br>

Dans cette catégorie on retient 4 candidats:

* **Docker**
Docker est la référence en matière de conteuneurisation. Il est l'outil le plus utilisé grâce à sa grande modularité. Il est aussi très performant.
* **Podman**
Podman est un bon concurrent, il reprend presque tout de Docker en étant plus léger (grâce au fait qu'il soit Daemonless). Il ne nécéssite d'ailleurs pas d'accès root.
Cependant c'est une technologie nouvelle avec des bugs et des fonctionnalités minimales. Par exemple, il n'a pas d'équivalent stable au docker-compose. Une technologie que j'affectionne particulièrement car elle permet de décrire (dans un fichier YAML) et de gérer (en ligne de commande) plusieurs conteneurs comme un ensemble de services inter-connectés.
* **Kubernetes (K3S)**
K3S est la version minimale de kubernetes, il est disponible pour les processeurs ARM. Cependant, étant un orchestrateur, il est prévu pour un grand nombre de conteneurs et permet surtout d'automatiser leur déploiement dans le but de faire de l'intégration continue.
* **OpenShift**
Basé sur kubernetes, il n'est pas prévu pour être utilisé sur les processeurs ARM (bien que cela soit possible en le recompilant).

J'ai décidé d'exclure OpenShift en premier lieu. Il a la même utilité que kubernetes tout en ne disposant pas d'une version pour les processeurs ARM. K3S est optimisé dans le cas d'un grand nombre de conteneurs (je l'ai déja vu utilisé dans un cluster de Raspberry). Dans notre cas il sera trop gourmand en ressource.
Le choix se fait donc entre Docker et Podman, ce dernier pourrait être une bonne solution mais il pose des problèmes de compatiblité avec Traefik (nous y reviendrons). Ces problèmes sont apparemment surmontables au prix d'heures de documentations. De plus, j'ai déja des compétence sur Docker.

Nous utiliserons donc **Docker**.

### Reverse-Proxy
Dans notre installation, nous aurons besoin d'un reverse-proxy afin de router les paquets vers le conteneur adéquat. Par exemple, l'utilisateur veut atteindre blog.phousse.fr, le reverse proxy s'occupe de rédiriger cette requête vers le container associé. Il permet aussi de gérer les certificats de chacune de nos applications web, de faire des redirections de ports facilement etc...
Il permet donc de gérer toutes les applications web de nos conteneurs, et plus encore...
Nous utiliserons **traefik v2** pour cela (cf annexe 2). Nginx aurait aussi pu être une solution, mais il est bien moins optimisé pour une utilisation avec Docker.

Ayant déja utilisé la v1 lors d'un projet précédent, je suis convaincu de l'efficacité de cet outil.
La v2 est beaucoup plus complète et plus optimisée.
La grosse nouveauté intéressante avec traefik v2, c'est qu'il supporte maintenant le protocole TCP (avec TLS). Cela va grandement nous simplifier la tâche pour installer notre serveur mail derrière traefik. 
Seul problème: La configuration est totalement différente et est bien plus complexe, il faudra donc se replonger dans la documentation.

### **Supervision**
La supervision est indispensable sur un système. Elle permet d'être conscient des erreurs si il y en a (et il y en aura) afin de les résoudre rapidement.

* **Nagios**
Longtemps considéré comme le leader du marché open-source en terme de supervision. Il est très efficace et très puissant.
Il est cependant compliqué à configurer.
* **Overmon**
Cet outil permet d’administrer simplement Overmon Server, ou tout simplement Nagios, de déployer des agents de supervision et d’inventaire, et bien plus encore.
C'est cependant une appliance VMware.
* **Prometheus/Graphana**
Prometheus est un sérieux candidat, ses programmes sont compilés pour les processeurs ARM. Il dispose d'une grosse communauté et est facile à mettre en place. De plus il est très économe en terme de ressources.
Graphana offre une superbe interface pour mettre en forme les données collectées.
* **Elastic Stack**
Composé de 3 produits open-source (Elastic Search, Logstash et Kibana).
Il permet de centraliser les logs grâce à Logstash, de les ordonner avec Elastic Search et de les visualiser dans une interface agréable avec Kibana.
De plus, il est relativement simple à déployer et à paramétrer. Il possède aussi un module permettant de faciliter son installation avec Traefik v2.

Le choix entre ELK (Elastic Stack) et Prometheus/Graphana est compliqué. Ils répondent tous les deux à nos besoins, ils sont légers et faciles à mettre en place. 
Mon choix sera donc purement subjectif car il se trouve que je veux expérimenter **Elastic search** depuis un moment et que l'occasion se présente.
### **Application webmail**
* **Roundcube**
* **Zimbra**
* **Rainloop**

Selon slant.co, Rainloop est le plus apprécié. Les 3 solutions proposées sont cependant assez équivalentes, il faudra donc les départager avec des détails.
**Rainloop** possède un avantage sur ses concurrents il ne nécéssite pas de base de données pour fonctionner.Ce qui en fait un outil moins gourmand. De plus son interface est plus moderne et plus agréable à utiliser.
### **Logiciel de gestion de version**
Nous jugerons les logiciels suivants sur leur accessibilité et sur leur consommation de ressources.
* **Gitlab**
RAM minimum annoncé par l'éditeur: **4Go**
Il est très efficace, possède une interface agréable et a beaucoup de fonctionnalités.
Problème: Il est beaucoup trop gourmand en ressources pour des fonctionnalités qui ne seront pas vraiment utiles. 
* **Gitea**
RAM minimum annoncé par l'éditeur: **1Go**
Un logiciel de git épuré et peu exigeant en ressources, il est très adapté à notre installation.
* **Bitbucket**
RAM minimum annoncé par l'éditeur: **1.5Go**
C'est un très bon logiciel mais il est payant pour avoir accès à toute les fonctionnalités.

Nous partirons donc sur **Gitea**.

### **CMS Blog**
Dans cette partie, j'attends du CMS qu'il soit léger, fluide et facile à prendre en main. Une gestion du markdown serait un plus.
* **Wordpress**
RAM minimum annoncé par l'éditeur: **1Go**
Il possède beaucoup de thèmes de qualité et de plugins, la communauté est nombreuse et très active.
Il equipe 32% du web à juste titre. J'ai eu l'occasion de l'utiliser et l'interface est intuitive et agréable. Cependant, lorsque je l'ai essayé j'ai remarqué un manque de fluidité lorsque les ressources ne suivent pas.
Il ne gère pas le Markdown
* **Ghost**
RAM minimum annoncé par l'éditeur: **650Mo**
CMS développé par un ancien responsable de l'équipe Wordpress.
Il est léger, intuitif et ne s'encombre que du nécessaire.
Et il a un avantage, l'écriture peut se faire en Markdown
* **Grav**
RAM minimum annoncé par l'éditeur: **500Mo**
C'est un CMS Flat-File. Cela signifie qu'il n'utilise pas de base de données mais des fichiers pour stocker l'information.
L'avantage principal est la rapidité.
Interface belle et intuitive, de nombreux thèmes et plugins disponibles.
L'installation est rapide, et surtout il gère le MARKDOWN !

Nous avons vu que Wordpress à tendance à être plutôt lent sur une petite installation. Nous choisirons donc entre les deux autres. 
Ils sont similaires mais **Grav** est plus léger et plus rapide grâce a son fonctionnement en flat-file.

## III- Déploiement

### Montage du boîtier
Le boîtier de ma Raspberry vient de AliExpress, mais il pourrait être différent. Vous trouverez de la documentation en ligne vous permettant le montage.
> Voici toutes les pièces composants mon boîtier :
<img src="https://i.imgur.com/mRvlJ4m.jpg" alt="drawing" width="400"/>
<img src="https://i.imgur.com/92ABlqe.jpg" width="400"/>

On commence le montage en plaçant les 4 dissipateurs de chaleur sur la carte (Voir photo ci-dessous).
<img src="https://i.imgur.com/GxD4uvt.jpg" width="300"/>

On peut maintenant fixer la Raspberry Pi sur le socle.
**Conseil:** placez d'abord les vis puis enfilez les pas de vis.
<img src="https://i.imgur.com/ADeqFav.jpg" width="300"/>

Il faut maintenant fixer le ventilateur sur son emplacement (étrangement, seulement 2 vis sont fournies avec mon boîtier, cela suffira).

<img src="https://i.imgur.com/vN70Ul1.jpg" width="300"/>

On branche le ventilateur sur les pins de la carte. 
**Attention :** Veillez à bien brancher le fil rouge sur le pin *5v* et le noir sur le pin *Ground* (Voir annexe 1).
<img src="https://i.imgur.com/fJAFU3G.jpg" width="300"/>

On continue en vissant les barres métalliques puis en plaçant les parois de la boîte.
<img src="https://i.imgur.com/OuXRXXV.jpg" width="300"/>

Finalement, on visse la plaque du dessus... Nous voilà fin prêts à faire du... **SOFTWARE !**
<img src="https://i.imgur.com/1Z6015O.jpg" width="300"/>

### Installation et paramétrage de l'OS

Pour installer raspbian, il faut écrire l'image sur la carte microsd.

**Ecrire l'image raspbian sur la carte microsd:**
>**Sous Linux**
>
>Nous nous rendons sur:
>https://www.raspberrypi.org/downloads/raspbian/
>
>On télécharge Raspbian Buster Lite.
>On liste tous les périphériques connectés à la machine.
>```
>pablo@lordi~$lsblk -p
>NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
>/dev/sda      8:0    0 238.5G  0 disk 
>├─/dev/sda1   8:1    0     2G  0 part [SWAP]
>├─/dev/sda2   8:2    0     2G  0 part /boot/efi
>├─/dev/sda3   8:3    0    40G  0 part /
>└─/dev/sda4   8:4    0 194.5G  0 part /home
>/dev/zram0  254:0    0 765.1M  0 disk [SWAP]
>```
>On insère la carte microsd sur notre machine à l'aide d'un adaptateur sd/microsd ou usb/microsd.
>Puis on liste à nouveau les périphériques.
>```
>pablo@lordi~$lsblk -p
>NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
>/dev/sda      8:0    0 238.5G  0 disk 
>├─/dev/sda1   8:1    0     2G  0 part [SWAP]
>├─/dev/sda2   8:2    0     2G  0 part /boot/efi
>├─/dev/sda3   8:3    0    40G  0 part /
>└─/dev/sda4   8:4    0 194.5G  0 part /home
>/dev/mmcblk0  8:3    0    32G  0 disk 
>/dev/zram0  254:0    0 765.1M  0 disk [SWAP]
>```
>On remarque que le disque **mmcblk0** est apparu  (il peut aussi apparaitre avec un nom de la forme sdX).
>
>On va maintenant écrire l'image sur la carte avec **dd**.
>**Soyez vigilants en utilisant cette commande**, si vous entrez le mauvais périphérique vous allez le formater.
>```
>sudo dd bs=4M if=2020-04-16-raspbian-buster.img of=/dev/mmcblk0 status=progress conv=fsync
>```


>**Sous Windows**
> 
>Rendez vous sur https://www.raspberrypi.org/downloads/
>Et téléchargez **Raspberry Pi Imager for Windows** .
>
>Insèrez la carte microsd sur votre machine à l'aide d'un adaptateur sd/microsd ou usb/microsd.
>
>Ouvrez **Raspberry Pi Imager** et choisissez Raspbian Buster Lite.
>
>Sélectionnez votre carte microsd et cliquez sur **WRITE**.

Il faut maintenant alimenter la Raspberry et la brancher sur un port ethernet de la box internet.

Une fois cela fait, il faut accèder à la page de configuration de votre routeur pour obtenir l'adresse IP attribuée à la Raspberry.
Chez moi, c'est *192.168.1.24* .

On peut maintenant se connecter:
```ssh pi@192.168.1.24```
> Le mot de passe par défaut est **raspberry**

Une fois qu'on est connecté on lance:
```sudo raspi-config```
On change le mot de passe.

Avec votre éditeur préféré (c'est forcément vim), ajoutez la ligne suivante dans le fichier **/home/pi/.bashrc**:
```TERM=xterm```
Puis tapez ```source .bashrc```

On vérifie maintenant qu'on a bien accès a internet:
```
pi@raspberrypi:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=54 time=12.3 ms
^C
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 12.291/12.291/12.291/0.000 ms
```
Il est temps de mettre à jour le système avec:
```sudo apt-get update && sudo apt-get upgrade```
Maintenant on reboot et on se reconnecte:
```
sudo reboot
ssh pi@192.168.1.24
```
Notre raspberry est fin prête à faire du docker.

### Installation de Docker
On commence par télécharger le script d'installation de docker avec:
```curl -fsSL https://get.docker.com -o get-docker.sh```
Puis on l'éxécute:
```
sudo chmod +x get-docker.sh
sudo sh get-docker.sh
```

A la fin de l'installation, on a des informations sur la version de docker installée:
```
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b
 Built:             Wed Mar 11 01:35:24 2020
 OS/Arch:           linux/arm
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b
  Built:            Wed Mar 11 01:29:22 2020
  OS/Arch:          linux/arm
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

On ajoute l'utilisateur pi au groupe docker afin d'avoir les droits pour manipuler les conteneurs:
```sudo usermod -aG docker pi```

Pour vérifier que l'installation se soit bien déroulée:
```
pi@raspberrypi:~$ docker run hello-world
[...]
Hello from Docker!
[...]
```
Si vous voyez le message "Hello from Docker !" c'est que votre installation est fonctionnelle.

Il nous manque juste quelques librairies ainsi et à installer docker-compose.
```
sudo apt-get install -y libffi-dev libssl-dev
sudo apt-get install -y python3 python3-pip
sudo apt-get remove python-configparser
sudo pip3 install docker-compose
```


### Déploiement de Traefik

On va commencer par créer les répertoires du container traefik et quelques fichiers nécéssaires (Nous verrons leur utilité plus tard).
```
sudo mkdir -p /opt/docker-compose/traefik/letsencrypt
sudo touch /opt/docker-compose/traefik/acme.json
sudo chmod 0600 /opt/docker-compose/traefik/acme.json
sudo touch /opt/docker-compose/traefik/traefik.toml
sudo mkdir /opt/docker-compose/traefik/logs
```

On crée maintenant le fichier /opt/docker-compose/traefik/docker-compose.yml.
Ce fichier défini un container, cela permet d'éviter les commandes Docker à rallonge et de faciliter les modifications.
```vim /opt/docker-compose/traefik/docker-compose.yml```
On y colle ceci:
```yaml=
version: '3.3'

services:
  traefik:
    image: traefik:2.2
    restart: always
    container_name: traefik
    ports:
      - 80:80
      - 443:443
      - 8080:8080
    networks:
      - external
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik/traefik.toml:/traefik.toml
      - ./traefik/acme.json:/acme.json
networks:
  external:
    external: true
```
**Explication du fichier:**

Ce fichier contient une configuration basique de traefik, nous serons amenés à la modifier plus tard.

*version: '3.3'* &rarr; C'est la version de docker-compose que nous utilisons.

*image: traefik:2.2* &rarr; Cette ligne indique quelle image Docker doit être utilisée, elle renvoie à l'image disponible à l'adresse : https://hub.docker.com/_/traefik . *:2.2* est le tag de l'image, autrement dit sa version.

*ports:* &rarr; Cette section indique la redirection de ports de la machine physique vers ce conteneur.

*network* &rarr; Cette section indique le réseau virtuel dont fait partie le conteneur.

*volumes* &rarr; Cette section indique les répertoires et fichiers partagés entre l'OS de la machine physique et le container. La premiere correspond au socket docker, elle est indispensable au bon fonctionnement du container.

La deuxième section "network" définie le (ou les) réseau virtuel utlisé dans le fichier.

**Options de démarrage:**

On va maintenant éditer le fichier **/opt/docker-compose/traefik/traefik/traefik.toml**
```yaml=
[global]
  sendAnonymousUsage = false

[log]
  level = "INFO"
  format = "common"

[providers]
  [providers.docker]
    endpoint = "unix:///var/run/docker.sock"
    watch = true
    exposedByDefault = true
    swarmMode = false

[api]
  dashboard = true
  debug = false
  insecure = true

[entryPoints]
  [entryPoints.web]
    address = ":80"
  [entryPoints.websecure]
    address = ":443"
```
Ce fichier contient la configuration de traefik, on y retrouve la configuration des logs, de notre provider (Docker) et des entrypoints.
Ces derniers font partie des nouveautés apportées par traefik v2. 
Je vous laisse consulter l'image en annexe 2 que je trouve assez explicite pour comprendre le fonctionnement de cette version 2.

Maintenant que notre configuration minimale est prête, on peut créer notre réseau virtuel et lancer le container:
```
sudo docker network create external
sudo docker-compose up -d
```
On peut maintenant accéder à l'interface web de traefik à l'adresse:
**http://[IP_raspberry]:8080**
<img src="https://i.imgur.com/k6FQ5M0.jpg" width="600"/>

Afin de faire nos tests locaux en conditions réelles, on peut ajouter la ligne suivante dans /etc/hosts de la Raspberry et de votre machine:
```
127.0.0.1    phousse.fr
```
On peut maintenant accéder à l'interface de traefik à l'adresse http://phousse.fr:8080

Bien que notre installation soit fonctionnelle, elle pose de vrais soucis de sécurité, il faut donc activer l'https (avoir des certificats) et protéger l'interface par un nom d'utilisateur et un mot de passe.
Aussi, nous ne voulons pas que l'interface web de traefik soit accessible à l'adresse phousse.fr mais plutôt à traefik.phousse.fr.
On en profitera pour activer les logs d'accès et les configurer.

**docker-compose.yml :**
```yaml=
version: '3.3'

services:
  traefik:
    image: traefik:2.2
    restart: always
    container_name: traefik
    ports:
      - 80:80
      - 443:443
#     - 8080:8080
    labels:
       - "traefik.enable=true"
       - "traefik.http.routers.${SUBDOMAIN}-web.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
       - "traefik.http.routers.${SUBDOMAIN}-web.entrypoints=web"
       - "traefik.http.routers.${SUBDOMAIN}-web.middlewares=${SUBDOMAIN}redirect"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.entrypoints=websecure"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.tls=true"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.middlewares=${SUBDOMAIN}-auth"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.tls.certresolver=letsencrypt"
       - "traefik.http.middlewares.${SUBDOMAIN}redirect.redirectscheme.scheme=https"
       - "traefik.http.middlewares.${SUBDOMAIN}-auth.basicauth.users=[USER:PASSWORD]"
       - "traefik.http.services.${SUBDOMAIN}.loadbalancer.server.port=8080"

    networks:
      - external
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./traefik.toml:/traefik.toml"
      - "./logs/traefik.log:/logs/traefik.log"
      - "./logs/access.log:/logs/access.log"
      - "./CustomRules:/CustomRules"
networks:
  external:
    external: true
```
Vous observerez que de nombreuses lignes sont apparues, en effet la section labels nous permet ici de configurer nos routers et nos middleware (cf annexe 2).
Pour faire simple on crée un router associant ce container au sous-domaine traefik.phousse.fr. 
On lui indique les deux entrypoints par lesquels il est joignable (Port http et https). 
On redirige ensuite tout le trafic arrivant sur l'entrypoint "web" (http) vers "secureweb" (https). Puis on active le TLS sur ce router.
On créé ensuite un middleware entre le router et le container afin de valider la requête par une authentification.
Pour finir on indique le port du container sur lequel est disponible le serveur web.

Vous n'avez qu'une chose à modifier dans le fichier docker-compose.yml, **[USER:PASSWORD]**. Cela correspond à l'utilisateur et au mot de passe pour se connecter à l'interface web de traefik via le middleware.

Remplacez donc [USER:PASSWORD] par **le retour de la commande suivante:**
```echo $(htpasswd -nb user password) | sed -e 's/\$/\$\$/g'```

Vous remarquerez que le fichier comporte 2 variables (**SUBDOMAIN** et **DOMAIN**).
Il faut donc créer un **fichier ".env"** dans le même répertoire que docker-compose.yml contenant ceci.
```
DOMAIN=phousse.fr
SUBDOMAIN=traefik
```
Remplacez phousse.fr par votre nom de domaine et traefik par ce que vous voulez.

**traefik.toml :**
```toml=
[global]
  sendAnonymousUsage = false

[log]
  level = "INFO"
  format = "json"
  filePath = "./logs/traefik.log"

[accessLog]
  format = "json"
  filePath = "./logs/access.log"
  bufferingSize = 100

[providers]
  [providers.docker]
    endpoint = "unix:///var/run/docker.sock"
    watch = true
    exposedByDefault = false
    swarmMode = false
    network = "external"

[api]
  dashboard = true
  debug = false
  insecure = true

[entryPoints]
  [entryPoints.web]
    address = ":80"
  [entryPoints.websecure]
    address = ":443"

[certificatesResolvers.letsencrypt.acme]
  storage = "letsencrypt/acme.json"
  email = "pablohousse@gmail.com"
  [certificatesResolvers.letsencrypt.acme.httpChallenge]
    entrypoint = "web"e
```
La aussi, on observe quelques ajouts.
On indique les fichiers dans lesquels les logs doivent être stockés et on change leur format en json afin qu'ils soient plus faciles, lisibles et exploitables.
On ajoute aussi une section "certificatesResolvers". Elle correspond à la configuration de **letsencrypt**, qui est une autorité de certification gratuite et qui va s'occuper de valider nos certificats.
Comme nous travaillons en local pour l'instant, celle-ci ne pourra pas les valider.

Il vous suffit de **modifier l'adresse mail associée à vos certificats** dans ce fichier.

Maintenant on crée les fichiers de logs puis on redémarre le container:
```
sudo mkdir /opt/docker-compose/traefik/logs
cd /opt/docker-compose/traefik/logs
sudo touch access.log traefik.log
sudo docker-compose down
sudo docker-compose up -d
```
> N'oubliez pas d'ajouter ```127.0.0.1    traefik.phousse.fr``` dans **/etc/hosts**

On peut maintenant accèder à https://traefik.phousse.fr
<img src="https://i.imgur.com/4chGGGQ.jpg" width="600"/>


On obtiendra une erreur de sécurité mais pas de panique, c'est normal... Nos certificats ne sont pas encore reconnus.

### Blog

Nous allons déployer un container du CMS Grav afin de publier cet article.

On commence par créer le répertoire qui va contenir le container ainsi que la configuration.

```sudo mkdir /opt/docker-compose/grav/```

Puis on crée le fichier /opt/docker-compose/grav/docker-compose.yml :

```yaml=
version: '3.3'
services:
  site:
    image: yobasystems/alpine-grav
    restart: always
    ports:
      - "8081:80"
    env_file:
      - ./grav.env
    labels:
       - "traefik.enable=true"
       - "traefik.http.routers.${SUBDOMAIN}-web.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
       - "traefik.http.routers.${SUBDOMAIN}-web.entrypoints=web"
       - "traefik.http.routers.${SUBDOMAIN}-web.middlewares=${SUBDOMAIN}redirect"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.entrypoints=websecure"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.tls=true"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.tls.certresolver=letsencrypt"
       - "traefik.http.middlewares.${SUBDOMAIN}redirect.redirectscheme.scheme=https"
    networks:
      - external
    volumes:
      - backup:/var/www/grav-admin/
volumes:
  backup:
    external: false
networks:
  external:
    external: true
```
Les labels sont les mêmes que pour le container précédent avec quelques lignes en moins car nous n'avons pas besoin de middleware pour l'authentification. De plus, le serveur web du container est accessible sur le port par défaut (80).

Nous avons indiqué dans le fichier docker-compose.yml que les variables d'environnement de ce container sont stockées dans le fichier **./grav.env**. Créons le dès à présent.
Celui-ci va contenir des informations essentielles à l'installation:
```
ADMIN_USER=admin
ADMIN_PASSWORD=xxxxxxx
ADMIN_EMAIL=pablohousse@gmail.com
ADMIN_PERMISSIONS=b
ADMIN_FULLNAME=Admin
ADMIN_TITLE=phousse
DOMAIN=phousse.fr
GENERATE_CERTS=false
```
Il vous faudra donc modifier les valeurs de ces variables par ce que vous souhaitez.
La variable **GENERATE_CERTS** est importante car elle indique au container qu'il ne doit pas générer de certificats. Ceux-ci seront gérés par traefik qui s'occupera de les créer et de les renouveler.

Pour finir, on crée le fichier .env:
```
DOMAIN=phousse.fr
SUBDOMAIN=blog
```

Nous avons maintenant accès à Grav.
<img src="https://i.imgur.com/0Q8YsuD.jpg" width="600"/>

### Logiciel de gestion de version

Nous allons maintenant déployer notre logiciel de gestion de version préféré: **Gitea** .
Celui-ci ne dispose pas d'image officielle compilée pour les processeurs ARM.
Il nous faut donc trouver une image de la communauté. 
Après quelques recherches, j'ai trouvé l'image **patrickthedev/gitea-rpi**. Il s'agit d'un clone de l'image officielle mais compilé pour les processeurs ARM.

Comme pour les autres services, nous commençons par créer le fichier **/opt/docker-compose/gitea/docker-compose.yml** .
```yaml=
version: "3.3"
services:
  gitea:
    image: patrickthedev/gitea-rpi
    restart: always
    networks:
      - external
    labels:
       - "traefik.enable=true"
       - "traefik.http.routers.${SUBDOMAIN}-web.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
       - "traefik.http.routers.${SUBDOMAIN}-web.entrypoints=web"
       - "traefik.http.routers.${SUBDOMAIN}-web.middlewares=${SUBDOMAIN}redirect"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.entrypoints=websecure"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.tls=true"
       - "traefik.http.routers.${SUBDOMAIN}-websecured.tls.certresolver=letsencrypt"
       - "traefik.http.middlewares.${SUBDOMAIN}redirect.redirectscheme.scheme=https"
       - "traefik.http.services.${SUBDOMAIN}.loadbalancer.server.port=3000"
    volumes:
      - ./data:/data
    ports:
      - "222:22"
      - "3000:3000"
networks:
  external:
    external: true
```
Rien de particulièrement remarquable dans ce fichier mis à part qu'on indique à traefik le port par lequel le serveur web est accessible:
```"traefik.http.services.${SUBDOMAIN}.loadbalancer.server.port=3000"```
Ce port peut être modifié après avoir lancé le container dans le fichier **/opt/docker-compose/gitea/data/gitea/conf/app.ini** .
A la ligne suivante:
```HTTP_PORT        = 3000```

Par souci de simplicité, je ne vais pas le modifier.

Vous commencez à être habitué, avant de lancer le container, on crée le fichier **/opt/docker-compsoe/gitea/.env** : 
```
SUBDOMAIN=git
DOMAIN=phousse.fr
```
On peut maintenant lancer le container avec:
```sudo docker-compose up -d```

Pour vérifier que le service est fonctionnel, on accède à git.phousse.fr.
<img src="https://i.imgur.com/Rmepw2N.jpg" width="600"/>

### Ouverture sur le monde

Pour que notre serveur ainsi que les services qu'il propose soient accessibles dans le monde entier, deux choses sont indispensables.
* Que la box internet redirige les requêtes (http, https, smtp) vers la Raspberry pi.

* Que le nom de domaine phousse.fr pointe vers l'adresse IPv4 publique de cette même box.

Nous allons donc voir ensemble comment faire cela:

#### Configuration de la box

Pour le premier point, cela se passe sur la page de configuration de la box.
Elle est souvent accessible à l'adresse 192.168.1.1 ou 192.168.1.254 (la première ou la dernière adresse de votre réseau).
Sur cette page il faudra faire deux choses:
* Ajouter la Raspberry à la DMZ (Zone démilitarisée)
C'est une zone accessible depuis internet et séparée du réseau local afin d'éviter les intrusions si une machine est compromise. 
* Ajouter des règles NAT/PAT pour rediriger le trafic qui nous intéresse vers la raspberry.

La marche à suivre étant différente pour chaque box, je vous invite à vous rendre sur le site web de votre opérateur afin de savoir comment accèder à ces configurations.
</br>
**On démilitarise !**

Comme écrit sur l'image ci-dessous, avant d'ajouter la Raspberry à la DMZ, il faut lui attribuer une adresse fixe.
<img src="https://i.imgur.com/XJmStwe.png" width="600"/>
</br>
**Les régles de redirection**

Pour l'instant nous n'aurons besoin que de 6 règles NAT/PAT:
* Ports 80 et 443 pour les redirections http et https. Cela permettra à nos applications web d'être accessibles.
* Ports 25, 587, 465 qui sont trois ports couramment utilisés par le protocole SMTP (Email).
* Port 22 pour ssh.
<img src="https://i.imgur.com/hzHamK8.png" width="500"/>


#### Configuration du DNS

Pour ce deuxième point, vous devrez dans un premier temps, louer un nom de domaine. 
Il existe de nombreuses entreprises proposant ce type de service (OVH, Cloudflare ...etc).
Pour ma part, j'héberge mon nom de domaine chez OVH (c'était le moins cher pour phousse.fr). Mais j'utilise cloudflare pour le configurer car l'interface est plus fluide, plus intuitive et plus simple.
En réalité vous avez accès sensiblement aux mêmes fonctionnalités chez tout les hébergeurs.

Maintenant que vous avez le contrôle sur votre nom de domaine préféré, il vous faut accéder à votre zone DNS.

Il faut ensuite configurer les enregistrements suivants:
<img src="https://i.imgur.com/VJWoU79.png" width="600"/>

Remplacez **90.113.10.126**, qui est mon adresse, par votre IPv4 publique et phousse.fr par votre nom de domaine.

Une fois cela fait, [domaine], git.[domaine], mail.[domaine], blog.[domaine], traefik.[domaine] et www.[domaine] pointent sur la même adresse IP.
C'est notre reverse proxy (Traefik) qui s'occupe ensuite de rediriger les réquêtes vers les containers adéquats.

#### Mise à jour des certificats

Maintenant que nos services sont disponibles dans le monde entier, il faut générer nos certificats. En effet, ceux utilisés jusqu'a maintenant étaient des certificats par défaut créés par Traefik.
**/!\ Attention** La procédé est différent que pour la version 1 de traefik

La méthode est maintenant la suivante:
```
sudo docker-compose down
sudo rm /opt/docker-compose/traefik/letsencrypt/acme.json
sudo docker-compose up -d
```
En supprimant le fichier contenant les certificats, on force letsencrypt à en générer de nouveaux.
### Service de mail

#### Serveur mail
Pour notre serveur mail, nous utiliserons l'image docker **tvial/docker-mailserver**.
Le gros avantage de cette image est qu'elle est facile et rapide à déployer et à configurer.
Seulement, celle-ci ne comprend aucune version compilée pour les processeurs ARM.
Nous allons donc créer notre image simplement avec la commande suivante:
```
docker build github.com/tomav/docker-mailserver -t arm/mailserver:latest
```
Cette commande va copier le repository github indiqué et l'utiliser pour créer l'image "arm/mailserver:latest". 
On pourrait se dire que l'image crée est un clone de celle disponible sur le hub docker. 
Cependant dans le fichier Dockerfile (fichier contenant toute les instructions permettant de construire l'image) on remarque que l'image de base utilisé est "debian:buster-slim". Cette image possède une version compilé pour les processeurs ARM. Celle-ci va être utilisé par défaut par "docker build" car on construit sur une machine de cette architecture.

Nous allons donc maintenant créer le répertoire ainsi que le fichier docker-compose.yml .
```bash
sudo mkdir /opt/docker-compose/mail/
```
Le fichier docker-compose.yml est le suivant:
```yaml=
version: '2'
services:
  mail:
    image: edgeux/mailserver:armhf
    restart: always
    hostname: ${SUBDOMAIN}
    domainname: ${DOMAIN}
    container_name: ${SUBDOMAIN}
    networks:
      - external
    ports:
      - "25:25"
      - "143:143"
      - "587:587"
      - "993:993"
    volumes:
      - ./maildata:/var/mail
      - ./mailstate:/var/mail-state
      - ./maillogs:/var/log/mail
      - ./config/:/tmp/docker-mailserver/
    env_file:
      - mailserver.env
    cap_add:
      - NET_ADMIN
      - SYS_PTRACE
networks:
  external:
    external: true
```
Il faut maintenant éditer le fichier **/opt/docker-compose/mail/.env** :
```
SUBDOMAIN=mail
DOMAIN=phousse.fr
```

On arrive maintenant à la grande force du projet **tvial/docker-mailserver**. 
En effet il propose un fichier **env-mailserver** qui comprend toute la configuration du serveur ainsi qu'un script **setup.sh** permettant entre autre de créer des adresses mail, de générer les certificats etc...

On récupère donc ces deux fichiers:
```bash
sudo curl -o mailserver.env https://raw.githubusercontent.com/tomav/docker-mailserver/master/env-mailserver.dist
sudo curl -o setup.sh https://raw.githubusercontent.com/tomav/docker-mailserver/master/setup.sh
sudo chmod +x ./setup.sh
```
Vous remarquerez que le fichier mailserver.env permet d'activer/désactiver des fonctionalités ainsi que de les configurer. 
Il est aussi très bien commenté et permet donc facilement de comprendre l'utilité de chaque ligne.

Voici les configurations que j'ai réalisés (les lignes qui ne sont pas indiquées ont gardé leur valeur par défaut):
```bash=
DMS_DEBUG=1
ONE_DIR=1
POSTMASTER_ADDRESS=contact@phousse.fr
# Rends cette machine disponible depuis le réseaux auquel elle est connectée
PERMIT_DOCKER=network
POSTFIX_INET_PROTOCOLS=ipv4
# Force la vérification de l'identité de l'expéditeur vant d'accepter le message
SPOOF_PROTECTION=1
ENABLE_POP3=1
# Clamav est un anti-virus puissant mais gourmand
ENABLE_CLAMAV=0
# Fail2ban permet de bannir des adresses détectées comme spam
ENABLE_FAIL2BAN=1
# Langage de filtrage de mails
ENABLE_MANAGESIEVE=1
# Un processus permettant de rejeter les messages spam le plus rapidement possible pour économiser des ressources
POSTSCREEN_ACTION=enforce
# Logiciel anti-spam
ENABLE_SPAMASSASSIN=1
SPAMASSASSIN_SPAM_TO_INBOX=1
MOVE_SPAM_TO_JUNK=1
SA_SPAM_SUBJECT=***SPAM*****
# Logiciel permettant d'extraire les mails du serveur avec IMAP ou POP3
ENABLE_FETCHMAIL=1
```
Comme nous avons activé fetchmail, il faut créer son fichier de configuration: **/opt/docker-compose/mail/mail_config/fetchmail.conf**
```
poll 127.0.0.1 proto IMAP
	user 'contact' there with
	password '[PASSWORD]'
	is 'contact@phousse.fr'
	ssl
poll 127.0.0.1 proto POP3
	user 'contact' there with
	password '[PASSWORD]'
	is 'contact@phousse.fr'
	ssl
```
Ce fichier contient les informations permettant à fetchmail de se connecter au serveur POP3/IMAP (Dovecot).

On peut maintenant lancer notre container:
```sudo docker-compose up -d```

En observant les logs du container, vous observerez que celui-ci ne peux pas démarrer car il a besoin d'une adresse mail.
C'est donc maintenant que nous allons utiliser le script **setup.sh** pour générer l'adresse contact@phousse.fr .
```sudo ./setup.sh mail add contact@phousse.fr [PASSWORD] ```

Puis on redémarre le container:
```
sudo docker-compose down
sudo docker-compose up -d
```
**Nous avons donc un serveur mail fonctionnel !**
Nous pouvons vérifier cela depuis une machine du réseau grâce à telnet:
```
 pablo@lordi:~ telnet 192.168.1.24 25                 
Trying 192.168.1.24...
Connected to 192.168.1.24.
Escape character is '^]'.
220 mail.phousse.fr ESMTP
ehlo mail.phousse.fr
250-mail.phousse.fr
250-PIPELINING
250-SIZE 10240000
250-ETRN
250-STARTTLS
250-AUTH PLAIN LOGIN
250-AUTH=PLAIN LOGIN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250-DSN
250 CHUNKING
mail from: test@testing.fr
250 2.1.0 Ok
rcpt to: contact@phousse.fr
data
250 2.1.5 Ok
354 End data with <CR><LF>.<CR><LF>
subject: test subject
test
.
250 2.0.0 Ok: queued as 191CF5EB4F
quit
221 2.0.0 Bye
Connection closed by foreign host.
```
Grâce à cette série de commande, on envoi un mail à l'adresse contact@phousse.fr. Il suffit maintenant de vérifier que le mail est bien arrivé à son destinataire.
Pour cela, il faut accéder au répertoire **/opt/docker-compose/mail/mails/phousse.fr/contact/new** .
On y trouve un fichier:
```
root@raspberrypi:/opt/docker-compose/mail/mails/phousse.fr/contact/new# cat 1591793596.M68953P6081.mail\,S\=1422\,W\=1453 
Return-Path: <test@testing.fr>
Delivered-To: contact@phousse.fr
Received: from mail.phousse.fr
	by mail.phousse.fr with LMTP
	id aSLYA7zX4F7BFwAAYenncw
	(envelope-from <test@testing.fr>)
	for <contact@phousse.fr>; Wed, 10 Jun 2020 12:53:16 +0000
Received: from localhost (localhost [127.0.0.1])
	by mail.phousse.fr (Postfix) with ESMTP id 0265F5EB9F
	for <contact@phousse.fr>; Wed, 10 Jun 2020 12:53:16 +0000 (UTC)
X-Quarantine-ID: <11l-6YDvaP-b>
X-Amavis-Alert: BAD HEADER SECTION, Missing required header field: "Date"
X-Spam-Flag: NO
X-Spam-Score: 4.74
X-Spam-Level: ****
X-Spam-Status: No, score=4.74 tagged_above=2 required=6.31
	tests=[ALL_TRUSTED=-1, FSL_BULK_SIG=0.001, MISSING_DATE=1.396,
	MISSING_FROM=1, MISSING_HEADERS=1.207, MISSING_MID=0.14,
	PYZOR_CHECK=1.985, TVD_SPACE_RATIO=0.001, T_SPF_TEMPERROR=0.01]
	autolearn=no autolearn_force=no
Received-SPF: Temperror (mailfrom) identity=mailfrom; client-ip=192.168.1.102; helo=mail.phousse.fr; envelope-from=test@testing.fr; receiver=<UNKNOWN> 
Authentication-Results:mail.phousse.fr; dkim=permerror (bad message/signature format)
Received: from mail.phousse.fr (lordi.home [192.168.1.102])
	by mail.phousse.fr (Postfix) with ESMTP id 191CF5EB4F
	for <contact@phousse.fr>; Wed, 10 Jun 2020 12:52:22 +0000 (UTC)
subject: test subject
Message-Id: <20200610125316.0265F5EB9F@mail.phousse.fr>
Date: Wed, 10 Jun 2020 12:53:16 +0000 (UTC)
From: test@testing.fr

test
```
Le problème est maintenant de pouvoir envoyer et recevoir des mails de l'extérieur.
Pour cela, nous avons un problème... Mon FAI (Orange) bloque le port 25 sortant de toute ses box non professionelles. Pour contourner cela, nous allons utiliser un relai SMTP sur le port 587.
Il en existe beaucoup mais j'ai choisi d'utiliser mailjet car ils proposent une offre gratuite (limitée à 200 mails par mois) et est très facile à utiliser.
On se rends sur https://www.mailjet.com/feature/smtp-relay/ et après avoir ouvert un compte il faut valider que le nom de domaine nous appartient (en mettant un enregistrement DNS particulier).
On obtient ensuite toutes les informations pour pouvoir se connecter au relais SMTP (API KEY, SECRET KEY et l'adresse du serveur).

Nous allons donc les renseigner dans le fichier **mailserver.env**:
```
RELAY_HOST=in-v3.mailjet.com
RELAY_PORT=587
RELAY_USER=xxxxxxxxxxxxxxxxxxxxxx
RELAY_PASSWORD=xxxxxxxxxxxxxxxxxxxx
```
Il nous faut maintenant configurer les enregistrement SPF et DKIM dans notre zone DNS .
* SPF (Sender Policy Framework): Cet enregistrement permet au destinataire d'un mail de s'assurer de l'identité de l'expéditeur.
* DKIM (DomainKeys Identified Mail): Cet enregistrement permet de fournir la clé publique d'un serveur afin de chiffrer les mails dont il est le destinataire (ou de s'assurer de l'identité de l'expéditeur).

On se rend sur https://app.mailjet.com/account/sender/domain_info/[DOMAIN] .
Sur cette page vous trouverez un outil indiquant les enregistrement à renseigner dans votre zone DNS ainsi qu'un outil permettant de les valider.

Pour le SPF, il suffit d'ajouter exactement la ligne indiqué (cela informe le destinataire d'un mail que le serveur mailjet est autorisé à relayer les mails de votre domaine).
<img src="https://i.imgur.com/fs8riFL.png" width="600"/>

Pour l'enregistrement DKIM, il faudra faire quelques manipulations sur le serveur:
```
$ cd /opt/docker-compose/mail
$ sudo ./setup.sh config dkim
$ sudo cat mail_config/opendkim/keys/phousse.fr/mail.txt
mail._domainkey	IN	TXT	( "v=DKIM1; h=sha256; k=rsa; "
	  "p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3m4/WXvHcB8U1O3Jb+k6BVEJTX9ivM9gfJFT9zFS9i10EmnwcTMEbeAMhNbXS1EmzWKGbdoG4iGX1XpxoVb6PpOpxMVXw8g3A/6zTmnWpImeyieUEGojgL87YD2lwatRDk9cc8LQW4uvLjg/SKgYkPWJe1Uce9OGmn28+bPzlxvxGGt7zX39QbAvndlisIkQU3L4Tum+8Gb+9j"
	  "IkiSwFlDS09bsN47/rTvoZbRCzhbU3XYogaR8UI/lS//ABPhxUOIZP3Il1Mfoc8RLVaORWaK0YPvltmgILUmw9VAooVsmQMMSyJZYHeu1jg0ymo2ogSvzw7eUG+4nPZhJkH/ChwQIDAQAB" )  ; ----- DKIM key mail for phousse.fr
```
**Explications:**
* On commence par se placer dans le répertoire du container.
* On appelle le script setup.sh qui va générer la paire de clés du serveur.
* On affiche le fichier mail.txt qui contient l'enregistrement DNS à renseigner.
Selon votre hébergeur, il peut demander différents formats pour les enregistrements DKIM. 
Cloudflare indique par exemple de supprimer les espaces et les guillemets afin de tout faire tenir sur une seule ligne.
Je vous laisse consulter la documentation de votre hébergeur pour le savoir.

Profitez d'être dans votre zone DNS pour ajouter les enregistrement suivant:
* Type A smtp.phousse.fr
* Type A mail.phousse.fr (Pour l'accès au webmail)
* Type MX smtp.phousse.fr

On se retrouve donc avec une zone DNS comme ceci:
<img src="https://i.imgur.com/oACtzFI.png" width="600"/>

#### Application Webmail
Comme pour le serveur mail, il n'existe pas d'image compilé pour les processeurs ARM. Cependant, l'image la plus utilisé de rainloop (hardware/rainloop) est construit à partir de l'image **alpine** et celle-ci possède une version pour notre architecture.

On commence donc par cloner le repository github:
```bash
cd
git clone https://github.com/hardware/rainloop.git
```
Puis on build l'image:
```
sudo docker build . -t arm/rainloop:latest
```
Nous allons maintenant ajouter rainloop au fichier docker-compose.yml de notre serveur mail:
```
cd /opt/docker-compose/mail
vim docker-compose.yml
```
Voici le fichier complet:
```yaml=
version: '2'
services:
  mail:
    image: arm/mailserver:latest
    restart: always
    hostname: smtp
    domainname: ${DOMAIN}
    container_name: smtp
    networks:
      internal:
        ipv4_address: 147.28.1.2
    ports:
      - "25:25"
      - "143:143"
      - "587:587"
      - "993:993"
    volumes:
      - ./mails:/var/mail
      - ./lib:/var/mail-state
      - ./logs:/var/log/mail
      - ./mail_config/:/tmp/docker-mailserver/
    env_file:
      - mailserver.env
    cap_add:
      - NET_ADMIN
      - SYS_PTRACE
  rainloop:
    image: arm/rainloop:latest
    env_file:
      - ./rainloop.env
    restart: always
    networks:
      - external
      - internal
    ports:
      - "8084:8888"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${SUBDOMAIN}-web.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
      - "traefik.http.routers.${SUBDOMAIN}-web.entrypoints=web"
      - "traefik.http.routers.${SUBDOMAIN}-web.middlewares=${SUBDOMAIN}redirect"
      - "traefik.http.routers.${SUBDOMAIN}-websecured.rule=Host(`${SUBDOMAIN}.${DOMAIN}`)"
      - "traefik.http.routers.${SUBDOMAIN}-websecured.entrypoints=websecure"
      - "traefik.http.routers.${SUBDOMAIN}-websecured.tls=true"
      - "traefik.http.routers.${SUBDOMAIN}-websecured.tls.certresolver=letsencrypt"
      - "traefik.http.middlewares.${SUBDOMAIN}redirect.redirectscheme.scheme=https"
      - "traefik.http.services.${SUBDOMAIN}.loadbalancer.server.port=8888"
    volumes:
      - ./rainloop_data/rainloop:/rainloop/data
networks:
  external:
    external: true
  internal:
    ipam:
      driver: default
      config:
        - subnet: 147.28.1.0/24
```
On peux maintenant démarrer les containers:
```
sudo docker-compose down
sudo docker-compose up -d
```
Pour configurer rainloop, il faut accéder à la page mail.phousse.fr/?admin. Les logs par défaut sont **admin et 12345**.
La première chose à faire est de modifier le mot de passe administrateur:
<img src="https://i.imgur.com/co9Ur6a.png" width="600"/>

Puis on configure le client IMAP afin que rainloop puisse extraire les mails du serveur:
Cliquez à gauche sur "Domaines" puis ajouter un domaine:
<img src="https://i.imgur.com/qlGnmzM.png" width="600"/>

Les deux conteneurs étant sur le même réseau, on peux indiquer l'adresse IP du serveur mail.

Pour finir, il faut ajouter l'identifiant contact à la whitelist.

On peux maintenant se connecter à contact@phousse.fr
<img src="https://i.imgur.com/QdtlEBL.png" width="600"/>


#### Tests finaux
Notre installation mail est donc finalement prête, passons au test finaux.
Nous pouvons nous assurer que tout est bien fonctionnel par 2 tests rapide:
* Envoyer un mail depuis rainloop vers une adresse gmail (qui sont les plus rigoureux en terme de sécurité)
* Envoyer un mail depuis un compte gmail vers le serveur.

<img src="https://i.imgur.com/81s8jfm.png" width="600"/>
<img src="https://i.imgur.com/ygbXYTv.png" width="600"/>
<img src="https://i.imgur.com/qz91d44.png" width="600"/>
<img src="https://i.imgur.com/UxlKYFe.png" width="600"/>

Tout est donc parfaitement fonctionel et nous pouvons passer à la suite.

### DynDNS
Cette partie n'était pas prévu mais j'ai remarqué au cours de mon installation que mon opérateur (Orange) utilise une allocation d'IP dynamique pour ses clients. 
Je devrais donc mettre à jour manuellement mon adresse IP dans ma zone DNS à chaque fois que celle-ci change.
Pour remédier à ce problème (car orange ne propose pas d'offre IP fixe pour les particuliers), nous allons utiliser le DNS dynamique avec l'outil **ddclient**.
Cet outil permet de modifier les enregistrements DNS en utilisant les API des hébergeurs.

Cependant le protocole de DNS dynamique de Cloudflare est particulié et n'est pas utilisable avec la version du paquet **ddclient**.
Il me faudra donc utiliser la dernière version sur github.
On commence par installer les librairies nécéssaires:
```
sudo apt-get install perl libdata-validate-ip-perl
```
On clone le repository de ddclient et on copie le fichier binaire dans /etc/bin/ afin de pouvoir l'utiliser facilement.
```
cd
git clone https://github.com/ddclient/ddclient.git
sudo cp -f ddclient/ddclient /usr/bin/
```
Il faut maintenant le configurer en créant le fichier /etc/ddclient/ddclient.conf:
```
sudo mkdir /etc/ddclient
sudo touch ddclient.conf
```
On y ajoute les lignes suivantes:
```
# Verification de l'IP toute les 600 secondes
daemon=600
# Activation des logs
syslog=yes
# On indique le protocole DynDNS utilisé
protocol=cloudflare
# Comme l'adresse IP que l'on veut vérifier est celle de la box internet, on utilise checkip.dyndns.org qui renvoi notre IP publique
use=web
web=checkip.dyndns.org/
web-skip=‘IP Address’
# On crypte les echanges avec l'API par sécurité
ssl=yes
# La zone DNS pour laquelle on veut modifier l'enregistrement
zone=phousse.fr
# Les identifiants de connexion à l'API cloudflare
login=[EMAIL]
password='[API_KEY]'
# Les enregistrements que nous voulons modifier
traefik.phousse.fr,blog.phousse.fr,mail.phousse.fr,git.phousse.fr,www.phousse.fr, phousse.fr, smtp.phousse.fr
```
On lance finalement le daemon avec:
```sudo ddclient -debug -verbose -noquiet```

### VPN
Pour notre serveur VPN, nous allons utiliser OpenVPN.
On ajoute le répertoire:
```sudo mkdir /opt/docker-compose/openvpn/```
On crée ensuite le fichier docker-compose.yml:
```
version: '2'
services:
  openvpn:
    image: darathor/openvpn
    cap_add:
     - NET_ADMIN
    container_name: openvpn
    ports:
     - "1194:1194/udp"
    restart: always
    volumes:
     - ./openvpn-data/conf:/etc/openvpn
```
"NET_ADMIN" permet au conteneur d'utiliser diverses outils réseaux.

Nous allons initialiser les fichiers de configurations et les certificats:
```
docker-compose run --rm openvpn ovpn_genconfig -u udp://phousse.fr
docker-compose run --rm openvpn ovpn_initpki
```
Puis générer le certificat de notre client:
```
docker-compose run --rm openvpn easyrsa build-client-full pablo
```
On extrait ensuite ces certificats avec:
```
docker-compose run --rm openvpn ovpn_getclient pablo > pablo.ovpn
```
On démarre le conteneur:
```
sudo docker-compose up -d
```
Il ne faut pas oublier d'ajouter une règle PAT sur la page de configuration de votre box pour rediriger les trames arrivant sur port 1194 vers la Raspberry

Le serveur VPN est maintenant prêt, on peux tester depuis un client:
``` 
pablo@lordi-/etc/openvpn/client $ openvpn /etc/openvpn/client/pablo.ovpn
Thu Jun 11 17:41:19 2020 OpenVPN 2.4.9 [git:makepkg/9b0dafca6c50b8bb+] x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Apr 20 2020
Thu Jun 11 17:41:19 2020 library versions: OpenSSL 1.1.1d  10 Sep 2019, LZO 2.10
Enter Private Key Password: ********
Thu Jun 11 17:41:23 2020 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
Thu Jun 11 17:41:23 2020 TCP/UDP: Preserving recently used remote address: [AF_INET]90.113.41.74:1194
Thu Jun 11 17:41:23 2020 UDP link local: (not bound)
Thu Jun 11 17:41:23 2020 UDP link remote: [AF_INET]90.113.41.74:1194
Thu Jun 11 17:41:23 2020 WARNING: 'link-mtu' is used inconsistently, local='link-mtu 1541', remote='link-mtu 1542'
Thu Jun 11 17:41:23 2020 WARNING: 'comp-lzo' is present in remote config but missing in local config, remote='comp-lzo'
Thu Jun 11 17:41:23 2020 [phousse.fr] Peer Connection Initiated with [AF_INET]90.113.41.74:1194
Thu Jun 11 17:41:24 2020 Options error: Unrecognized option or missing or extra parameter(s) in [PUSH-OPTIONS]:1: block-outside-dns (2.4.9)
Thu Jun 11 17:41:24 2020 TUN/TAP device tun0 opened
Thu Jun 11 17:41:24 2020 /usr/bin/ip link set dev tun0 up mtu 1500
Thu Jun 11 17:41:24 2020 /usr/bin/ip addr add dev tun0 local 192.168.255.6 peer 192.168.255.5
Thu Jun 11 17:41:24 2020 Initialization Sequence Completed
```
La connexion est bien initialisée, le serveur est fonctionel.


### Portfolio

Pour le portfolio, il suffira d'installer un serveur apache/php .
Cependant, pour les besoins d'un projet disponible sur mon portfolio, je dois ajouter quelques paquets à ce conteneur. Il faut donc build une nouvelle image.
```
wget https://raw.githubusercontent.com/LavoWeb/Docker/master/PHP/7.2/Dockerfile
```
J'ajoute les paquets (traceroute, host et graphviz) et je build l'image:
```
sudo docker build . -t phousse/lamp_arm
```
On édite le fichier docker-compose.yml :
```yaml=
version: '3'
services:
    php-apache:
        image: phousse/lamp_arm
        ports:
          - 8085:80
        restart: always
        volumes:
          - ./DocumentRoot:/var/www/html:z
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.${SUBDOMAIN}-web.rule=Host(`${DOMAIN}`)"
          - "traefik.http.routers.${SUBDOMAIN}-web.entrypoints=web"
          - "traefik.http.routers.${SUBDOMAIN}-web.middlewares=${SUBDOMAIN}redirect"
          - "traefik.http.routers.${SUBDOMAIN}-websecured.rule=Host(`${DOMAIN}`)"
          - "traefik.http.routers.${SUBDOMAIN}-websecured.entrypoints=websecure"
          - "traefik.http.routers.${SUBDOMAIN}-websecured.tls=true"
          - "traefik.http.routers.${SUBDOMAIN}-websecured.tls.certresolver=letsencrypt"
          - "traefik.http.middlewares.${SUBDOMAIN}redirect.redirectscheme.scheme=https"
        networks:
          - external
networks:
   external:
      external: true
```
Et ensuite le fichier **.env**:
```
DOMAIN=phousse.fr
SUBDOMAIN=php
```
Mettons les fichiers du site web dans le dossier DocumentRoot, le portfolio est maintenant accessible à l'adresse phousse.fr

### Supervision

C'est le moment déployer la supervision de la Raspberry.
```mkdir /opt/docker-compose/supervision```
On crée le fichier docker-compose.yml pour elastic stack:
```yaml=
version: '3.7'
services:
  elasticsearch:
    image: pestotoast/elasticsearch-armhf 
    container_name: elasticsearch
    volumes:
      - ./es_data:/usr/share/elasticsearch/data
    env_file:
      - elasticsearch.env
    networks:
      elastic:
        ipv4_address: 172.22.0.4
  kibana:
    image: deepakdpk6/kibanaforarm
    container_name: kibana
    env_file:
      - kibana.env
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.kibana.rule=Host(`kibana.phousse.fr`)"
      - "traefik.http.routers.kibana-web.entrypoints=web"
      - "traefik.http.routers.kibana-web.middlewares=kibanaredirect"
      - "traefik.http.routers.kibana-websecured.rule=Host(`kibana.phousse.fr`)"
      - "traefik.http.routers.kibana-websecured.entrypoints=websecure"
      - "traefik.http.routers.kibana-websecured.tls=true"
      - "traefik.http.routers.kibana-websecured.tls.certresolver=letsencrypt"
      - "traefik.http.services.kibana.loadbalancer.server.port=5601"
    networks:
      elastic:
        ipv4_address: 172.22.0.5
      external:
  logstash:
    image: ewalkerhjt/logstash_rpi
    container_name: logstash
    volumes: 
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
    networks:
      elastic:
        ipv4_address: 172.22.0.6
networks:
  elastic:
    ipam:
      driver: default
      config:
        - subnet: 172.22.0.0/16
  external:
    external: true
```
On ajoute ensuite les fichiers contenant les variables d'environnements et les configurations:

**elasticsearch.env :**
```
# On limite l'utilisation de la RAM à 512 Mo
ES_JAVA_OPTS=-Xms512m -Xmx512m
transport.host=localhost
transport.tcp.port=9300
http.port=9200
http.host=0.0.0.0
```

**kibana.env :**

```
ELASTICSEARCH_HOST= 'http://172.22.0.4:9200'
ELASTICSEARCH_USERNAME= 'elastic'
ELASTICSEARCH_PASSWORD= '#elastic#'
# Désactive le monitoring
XPACK_MONITORING_ENABLED= 'false'
```

**logstash.conf :**
```
output {
    elasticsearch {
      hosts => "http://172.22.0.4:9200"
# Indique le format des logs
      index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
```
En démarrant ces conteneurs, tout semble fonctionner. 
Cependant, je me suis rapidement aperçu que cela fournissait une énorme quantité de logs (environ 20Go de données en 1 jour). J'ai donc décidé de l'arrêter. Pour activer cette supervision, je prévois d'utiliser un disque dur sur la Raspberry pour stocker les logs.

## Conclusion
Nous avons désormais un serveur répondant aux besoins que nous avions fixé, à l'exception de la supervision. Ce projet à été très intérréssant à mettre en oeuvre, il m'a permis d'explorer de nouvelles technologies et de compléter mes connaissances en administration système.
Pour achever ce projet, j'ai commandé un disque SSD ainsi qu'un adaptateur SATA - USB-C afin palier au problème du poids des logs et ainsi mettre en place la supervision. J'envisage aussi d'écrire un script bash automatisant le déploiement de ce serveur.

Je suis particulièrement satisfait de cette Raspberry pi 4 4Go, elle surpasse de loin toute les précédentes et laisse présager de  nombreuses possibilités pour le futur de ces petites machines.
J'ai d'ailleurs appris récemment qu'une nouvelle Raspberry pi était annoncée avec cette fois 8Go de RAM. De tels caractéristiques pourraient donner un sens à des projets comme K3S. 
Je me réjouis d'explorer ces nouvelles prossibilités !

## Annexes
**Annexe 1:**
![](https://i.imgur.com/txegHxo.jpg)

**Annexe 2:**
![](https://i.imgur.com/EEUrCJf.png)


## Sources
https://www.raspberrypi-france.fr/guide/systeme-exploitation-raspberry-pi/
docs.traefik.io
https://github.com/tomav/docker-mailserver/wiki
https://hub.docker.com


