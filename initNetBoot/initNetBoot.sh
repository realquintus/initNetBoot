#!/bin/bash
usage(){
	echo -e "\e[1mInitNetBoot.sh\e[0m is a bash script that is used to initialize a network boot server using PXE.\nFirstly, it will install/update dependencies, then configure and enable DHCP and TFTP server.\n\t\e[1m\e[4mOptions:\e[0m\e[0m\n\t\t-h : Show this help message.\n\t\t-f : This option is needed and is used to indicate the image that you want to be available on the local network.\n\t\t-I : This option is required and is used to indicates the network interface through which the server will be available.\n\t\t-v : Verbose mode\n\t\t-N : This option is not required and permit to not install needed packages, use it only if you already have them.\n\t\t-l : This option is not required and permit to make available a live image on the network. Make sure to a compatible image. If this option is not entered the image will be installed on the PXE client."
}
######## Handling options ##########################
while getopts "f:vI:hNl" option;do
	case $option in
		f)
			if [ -e $OPTARG ];then
				image=$OPTARG
			else
				echo -e "Error, file does not exist"
				usage
				exit 1
			fi
		;;
		v)
			verb="true"
		;;
		I)
			ip a s $OPTARG 2> /dev/null > /dev/null
			if [ $? -eq 0 ];then
				interface=$OPTARG
			else
				echo "The specified network interface does not exist"
				exit 2
			fi
		;;
		h)
			usage
			exit 0
		;;
		N)
			no_install="true"
		;;								
		l)
			live="true"
		;;
	esac
done
###########################################################

############# Configuring network interface #########
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
#################################################

  if [ -z $image ] || [ -z $interface ];then
	echo "An information is missing, please read the following message:"
	usage
	exit 4
fi

#################### Installing/updating dependencies #############################################
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
#################################################################################################

######## Creating tftp folder #################
if [[ $verb = "true" ]];then
	echo "Creating tftp's folder: /var/tftpboot/"
fi
sudo mkdir -p /var/tftpboot/pxelinux.cfg/
if [ -n $live ];then
	if [[ $verb = "true" ]];then
		echo "Creating NFS and live folders: /var/tftpboot/nfs and /var/tftpboot/live/"
	fi
	mkdir /var/tftpboot/live/ /var/tftpboot/nfs
fi
###############################################

###################### Creating boot menu ########################
if [[ $verb = "true" ]];then
	echo "Loading boot menu in /var/tftpboot/pxelinux.cfg"
fi
if [ -z $live ];then
	sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')pxe_installation.menu /var/tftpboot/pxelinux.cfg/default
else
	sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')pxe_live.menu /var/tftpboot/pxelinux.cfg/default
fi
###################################################################################################

################ Get needed library and put it in tftp folder ######################################
if [[ $verb = "true" ]];then
	echo "Copying needed library in tftp folder..."
fi
if [ -z $(ls /var/tftpboot/ | grep pxelinux.0) ];then
	sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')lib/* /var/tftpboot/
fi
####################################################################################################

################ Make the image available on the network ############
if [ -z $live ];then
	if [[ $verb = "true" ]];then
		echo "Copying netboot image on tftp folder..."
	fi
	file_exten=$(echo $image | awk -F "." '{print $NF}')
	sudo cp $image /var/tftpboot/netboot_image.$(echo $file_exten)
else
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
	if [[ $verb = "true" ]];then
		echo "Copying kernel and base system in /var/tftpboot/live"
	fi
	cp /var/tftpboot/nfs/casper/{initrd,vmlinuz} /var/tftpboot/live/
	if [[ $verb = "true" ]];then
		echo "Configuring NFS"
	fi
	if [ -z "$(cat /etc/exports | grep -o '/var/tftpboot/nfs 192.168.55.0/24(sync,no_root_squash,no_subtree_check,ro)')" ];then
		rm /etc/exports
		cp $(echo $0 | sed 's/initNetBoot.sh//g')nfs.config /etc/exports
	fi
	if [[ $verb = "true" ]];then
		echo "Initializing NFS server"
	fi
	systemctl start nfs-server.service
	exportfs -a
fi
#####################################################################

############ Configure dnsmasq ########################################
if [[ $verb = "true" ]];then
	echo "Configuring dnsmasq..."
fi
cat $(echo $0 | sed 's/initNetBoot.sh//g')dnsmasq.conf | sed "s/%NIC%/$interface/g" > /etc/dnsmasq.conf
if [[ $verb = "true" ]];then
	echo "Restarting dnsmasq..."
fi
systemctl restart dnsmasq.service
#######################################################################
