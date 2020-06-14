#!/bin/bash
while getopts "l:pc" option;do
	case $option in
		l)
			login=$OPTARG
		;;
		p)
			private_dir="true"
		;;
		c)
			clear="true"
		;;
	esac
done
if [ -n $login ] && [ -z $private_dir ] && [ -z $clear ];then
	apt-get install -y nfs-common
	mkdir /mnt/nfs_users/ 2> /dev/null
	echo $login
	mount -t nfs 192.168.55.254:/var/nfs_server/users/ /mnt/nfs_users/
	echo $(ip a | grep -o "192.168.55.*/24" | cut -d "/" -f1) > /mnt/nfs_users/$login
	echo $login > /tmp/nfs_client.tmp
elif [ -n $private_dir ] && [ -z $login ] && [ -z $clear ];then
	mkdir /mnt/save 2> /dev/null
	umount /mnt/nfs_users
	mount -t nfs 192.168.55.254:/var/nfs_server/auth/$(cat /tmp/nfs_client.tmp) /mnt/save/	
elif [ -n $clear ] && [ -z $login ] && [ -z $private_dir ];then
	umount -f /mnt/nfs-server 2> /dev/null
	umount -f /mnt/save 2> /dev/null
fi

