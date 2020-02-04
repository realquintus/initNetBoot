#!/bin/bash

while getopts "f:v" option;do
	case $option in
		f)
			if [ -e $OPTARG ];then
				image=$OPTARG
			else
				echo -e "Error, file does not exist"
				exit 1
			fi
		;;
		v)
			verb="true"
		;;
	esac
done
# Checking if server is using UEFI, if not, it might cause problem like break your PC
[ -d /sys/firmware/efi ] && efi="true" || efi="false"
#################### Installing/updating dependencies ##########################################################################
lib=$(ls /var/lib/)												  	       #
[ -z $(echo $lib | grep apt) ] 2> /dev/null || install_command="apt install -y dnsmasq syslinux-common"  #
[ -z $(echo $lib | grep pacman) ] 2> /dev/null || install_command="pacman -Sy --noconfirm dnsmasq syslinux"      #
[ -z $(echo $lib | grep yum) ] 2> /dev/null || install_command="yum install -y dnsmasq syslinux"       #
if [[ $verb = "true" ]];then												       #
	echo $install_command												       #
fi															       #
eval $install_command													       #
################################################################################################################################
# Creating tftp folder
if [[ $verb = "true" ]];then
	echo "Creating tftp's file"
fi
sudo mkdir -p /var/lib/tftpboot/pxelinux.cfg/
# Creating boot menu
if [[ $verb = "true" ]];then
	echo "Loading boot menu in "
fi
sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')pxelinux_menu.txt /var/lib/tftpboot/pxelinux.cfg/default 

################ Get needed library and put it in tftp folder #####################################################
cd /														  #
path_lib=$(locate -e pxelinux.0 | grep -E /pxelinux.0$ | sed 's/\/pxelinux.0//g' )				  #
if [ -z $(ls /var/lib/tftpboot/ | grep pxelinux.0) ];then							  #
	cp -r $(echo $path_lib)/{pxelinux.0,vesamenu.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot/ #
fi														  #
###################################################################################################################

#cd /var/lib/tftpboot/
#sudo cp /usr/lib/PXELINUX/pxelinux.cfg .
#sudo cp /usr/lib/syslinux/memdisk .
#sudo cp /usr/lib/syslinux/modules/bios/* .
#sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old

################ Make the image available on the network ############
file_exten=$(echo $image | awk -F "." '{print $NF}')		    #
sudo cp $image /var/lib/tftpboot/netboot_image.$(echo $file_exten)  #
#####################################################################
