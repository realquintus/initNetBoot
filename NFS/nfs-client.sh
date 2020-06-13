#!/bin/bash
while getopts "l:p" option;do
	case $option in
		e)
			login=$OPTARG
		;;
		s)
			private_dir="true"
		;;
	esac
done
if [ -n $login ] && [ -z $private_dir ];then
	apt-get install -y nfs-common
	mkdir /mnt/nfs_users/
	mount -t nfs -o sync,no_root_squash,no_subtree_check,rw 192.168.55.254:/var/nfs-server/users/ /mnt/nfs_users/
	echo $(ip a | grep -o "192.168.55.*/24" | cut -d "/" -f1) > /mnt/nfs_users/$login
	echo $login > /tmp/nfs_client.tmp
elif [ -n $private_dir ] && [ -z $login ];then
	mkdir ~/shared/
	mount -t nfs -o sync,no_root_squash,no_subtree_check,rw 192.168.55.254:/var/nfs-server/auth/$(cat /tmp/nfs_client.tmp) ~/shared/	
fi

