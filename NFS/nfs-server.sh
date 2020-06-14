#!/bin/bash
usage() {
	echo -e "\e[1mnfs-server.sh\e[0m is a bash script that permit a kind of authenfication by IP addresses. It have to be used in three steps:\n\n\t-Firstly run it with -e option to allow the local network to access the /var/nfs-server/users directory. All the clients of the network have to create a file named as their login with their IP address in it.\n\n\t-When all clients have done the precious step, run this script with -s option to create a directory for each user in /var/nfs-server/auth. It will only allow the access of each directory to the related IP address. The clients can now upload or download files in their repectives directories.\n\n\t-Finally, when the session is over, you can run the script with -c option. It will stop the NFS server, clear the /var/nfs-server/users/ directory and the access of all personals folders."
}
while getopts "esch" option;do							#
	case $option in									#
		e)									#
			etu="true"	
		;;									#
		s)									#
			secure="true"							#
		;;									#
		c)
			clean="true"
		;;
		h)
			usage
			exit 0
		;;
	esac
done
if [ -n $etu ] && [ -z $secure ] && [ -z $clean ];then		
	mkdir -p /var/nfs_server/users 2> /dev/null
	if [[ $(cat /etc/exports | grep "nfs_server/users 192.168.1.0") == "" ]];then
		echo "/var/nfs_server/users 192.168.55.0/24(sync,no_root_squash,no_subtree_check,rw)" >> /etc/exports
	fi
	systemctl restart nfs-server
	exit 0
fi
if [ -n $secure ] && [ -z $etu ] && [ -z $clean ];then
	mkdir /var/nfs_server/auth/ 2> /dev/null
	for user in $(ls /var/nfs_server/users);do
		mkdir /var/nfs_server/auth/$user 2> /dev/null
		echo "/var/nfs_server/auth/$user $(cat /var/nfs_server/users/$user)/24(sync,no_root_squash,no_subtree_check,rw)" >> /etc/exports
	done
	systemctl restart nfs-server
	exit 0
fi
if [ -n $clean ] && [ -z $etu ] && [ -z $secure ];then
	systemctl stop nfs-server
	echo "/var/tftpboot/nfs 192.168.55.0/24(sync,no_root_squash,no_subtree_check,ro)" > /etc/exports
	rm -rf /var/nfs_server/users/*
	exit 0
fi
