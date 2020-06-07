#!/bin/bash
usage(){
	echo -e "cleanNetBoot is a bash script that revert the initNetBoot script."
}
####### Handling options ################
while getopts "Fnhv" option;do
	case $option in
		h)
			usage
			exit 1
		;;
		v)
			verb="true"
		;;
		F)
			full_clean="true"
		;;
		n)
			no_confirm="true"
		;;
	esac
done
##########################################

####### Configuring network interface ####
NIC=$(ip a s | grep "192.168.9.254/24" | awk '{print $NF}' | grep -E "*")
if [ $? -ne 1 ] && [[ -n $full_clean ]];then
	if [ -z $no_confirm ];then
		echo "Do you want to flush $NIC IP address (Y/n):"
		read confirm_NIC
		${confirm_NIC-"y"}
	fi
	if [ -n $no_confirm ] || [[ $confirm_NIC == "Y" ]] || [[ $confirm_NIC == "y" ]];then
		ip a f dev $NIC
	fi
	if [[ $verb = "true" ]];then
		echo "Flushing IP adresse on interface $NIC"
	fi
fi
#########################################

######## removing dependencies ##########
if [ -n $full_clean ];then
	lib=$(ls /var/lib)
	if ! [ -z $(echo $lib | grep -o "apt") ];then
		remove_command="apt remove -y ""$(if [ -z $verb ];then echo '-q ';fi)""dnsmasq pxelinux syslinux-common nfs-kernel-server"
	elif ! [ -z $(echo $lib | grep -o "pacman") ];then
		remove_command="pacman -Rsy $(if [ -z $verb ];then echo '-q ';fi)--noconfirm dnsmasq pxelinux syslinux nfs-utils"
	elif ! [ -z $(echo $lib | grep -o "yum") ];then
		remove_command="yum remove -y $(if [ -z $verb ];then echo '-q ';fi)dnsmasq pxelinux syslinux nfs-utils"
	else
		echo "Warning: Your package manager is not detected, you can delete dnsmasqu, pxelinux syslinux nfs-utils packages manually"
	fi
	if [ -z $no_confirm ];then
		echo "Do you want to remove dnsmasq, pxelinux,syslinux-common, nfs-utils (Y/n):"
		read confirm_packages
		${confirm_packages-"y"}
	fi
	if [ -z $no_confirm ] || [[ $confirm_packages == "y" ]] || [[ $confirm_packages == "Y" ]];then
		if [[ $verb = "true" ]];then
			echo -e "\n## Removing packages: $install_command ##"
		else
			install_command="$install_command"" > /dev/null"
		fi
		eval $install_command
		if [[ $verb = "true" ]];then
			echo -e "## Remove finished ##\n"
		fi
fi
######################################

######## Cleaning tftp folder #################
if [ -z $no_confirm ];then
	echo "Do you want to clean tftp folder, if you entered full clean option it will delete all of it. If not it will simply delete the current image (Y/n):"
	read confirm_folder
	${confirm_folder-"y"}
fi
if [ -z $no_confirm ] || [[ $confirm_folder == "y" ]] || [[ $confirm_folder == "Y" ]];then
	if [[ $verb = "true" ]];then		      #
		echo "Cleaning tftp's folder: /var/tftpboot/"	      #
	fi
	if [ -z $full_clean ];then
		rm -rf /var/tftpboot/live/* /var/tftpboot/nfs/* /var/tftpboot/pxelinux.cfg/*
	else
		rm -rf /var/tftpboot/
	fi
fi
###############################################
