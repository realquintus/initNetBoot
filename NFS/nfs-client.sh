#!/bin/bash
while getopts "l:p" option;do
	case $option in
		l)
			login=$OPTARG
		;;
		p)
			private_dir="true"
		;;
	esac
done
if [ -n $login ] && [ -z $private_dir ];then
	apt-get install -y nfs-common
	mkdir /mnt/nfs_users/ 2> /dev/null
	echo $login
	mount -t nfs 192.168.55.254:/var/nfs_server/users/ /mnt/nfs_users/
	echo $(ip a | grep -o "192.168.55.*/24" | cut -d "/" -f1) > /mnt/nfs_users/$login
	echo $login > /tmp/nfs_client.tmp
elif [ -n $private_dir ] && [ -z $login ];then
	mkdir /mnt/save 2> /dev/null
	umount /mnt/nfs_users
	mount -t nfs 192.168.55.254:/var/nfs_server/auth/$(cat /tmp/nfs_client.tmp) /mnt/save/	
fi

