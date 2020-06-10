#!/bin/bash
echo "bonjour nous allons installer la dernière version de NFS."
apt-get install -y nfs-kernel-server
read -p "Quel est le nom du fichier comprenant le nom des étudiants ou le chemin complet si le fichier n'est pas dans le même répertoire que ce script ?" test
 
etu=$(echo `cat $test`)

#nbr=$(wc -w $etu)

for eleve in $etu
do
echo "/$eleve $eleve.home(rw)" >> /etc/exports
done
echo "voulez vous redémarer le service ?"
read question
echo "$question"
if [ "$question" = "oui" ]
then
service nfs-kernel-server restart
sleep 10
echo "L'installation et le paramétrage est fini" 
else
echo "le service n'a pas redémaré"
fi
