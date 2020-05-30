## NFS
Nous avons désormais besoin de créer un partage de fichier entre le professeur et les étudiants.
Pour se faire nous allons utiliser NFS.

NFS est un outil très utile qui permet à un utilisateur de consulter et, éventuellement, de stocker et de mettre à jour des fichiers sur un ordinateur distant.
Pour l'utiliser au minimun nous avons besoin de 2 machines, un serveur et un client.

- Sur le serveur nous devons installer :
```
 apt-get install nfs-kernel-server
 ```
 Ensuite pour le configurer il faut aller dans le fichier :
 ```
vim /etc/exports
```
exemple :
```
/partage 192.168.1.23(rw)
```
/partage      -> le dossier à partager 
192.168.1.23  -> IP du client, 
Il est aussi possible de rentrer une plage d'adresse, aussi un DNS. 
(rw)          -> le dossier est accecible en lecture écriture.

- Sur le client nous devons installer :
```
apt-get install nfs-common
```
Nous allons effectué un montage automatique à l'aide de ce fichier.
```
/etc/fstab
```
Dans lequel il faut renseigner :
```
192.168.1.22:/patage /paratge_nfs nfs4 rw 0 0
```
192.168.1.22:/patage -> IP et dossier du serveur
/paratge_nfs         -> dossier du client, là où il va receptionner et envoyer de documents. 
nfs4 rw              -> la version de NFS et la lecture écriture
0 0                  -> option de vidage et tentative en cas d’échecs 

On utilise cette commande pour verifier le montage
```
Df -h
```
L'inconvénient est que la dernière version de NFS est désormais plus difficile à configurer dès que l'on veut utiliser des fonctions de sécurité de base telles que l'authentification et le chiffrement, puisqu'il repose sur Kerberos pour ces fonctionnalités.

Et sans ces deux dernières, l'utilisation du protocole NFS doit se limiter à un réseau local de confiance car les données qui circulent sur le réseau ne sont pas chiffrées (un sniffer peut les intercepter) et les droits d'accès sont accordés en fonction de l'adresse IP du client (qui peut être usurpée).

NFS
https://www.netapp.com/fr/communities/tech-ontap/nfsv4-0508-fr.aspx
https://help.ubuntu.com/community/NFSv4Howto
https://fr.wikipedia.org/wiki/Network_File_System
https://linux.developpez.com/formation_debian/nfs.html
Kerberos + NFS
https://docs.oracle.com/cd/E24843_01/html/E23285/setup-97.html
https://wiki.debian.org/NFS/Kerberos
https://debian-handbook.info/browse/fr-FR/stable/sect.nfs-file-server.html

Kerberos
https://docs.oracle.com/cd/E24843_01/html/E23285/setup-148.html#seamtask-436
https://ubuntu.com/server/docs/service-kerberos
https://guide.ubuntu-fr.org/server/kerberos.html
https://web.mit.edu/kerberos/www/krb5-latest/doc/admin/install_kdc.html
https://www.tartarefr.eu/test-wiki-2/
https://blog.devensys.com/wp-content/uploads/2018/08/Infographie_Kerberos_plaquette.pdf
https://blog.devensys.com/kerberos-principe-de-fonctionnement/
https://linux.die.net/man/1/kinit
https://docs.oracle.com/cd/E23941_01/E26840/html/kerberos-auth.html
https://docs.oracle.com/cd/E24843_01/html/E23285/intro-1.html#scrolltoc
