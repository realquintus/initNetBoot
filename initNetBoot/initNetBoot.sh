#!/bin/bash

while getopts "f:" option;do
	case $option in
		f)
			if [ -e $OPTARG ];then
				echo -e "Error, file does not exist"
				exit 1
			fi
			image=$OPTARG	
	esac
done
#################### Installing/updating dependencies #############################################################
lib=$(ls /var/lib/)												  #
[ -n $(echo $lib | grep apt) ] || install_command="apt install -y dnsmasq tftpd syslinux-common isc-dhcp-server"  #
[ -n $(echo $lib | grep pacman) ] || install_command="pacman -Sy --noconfirm dnsmasq tftp-hpa syslinux dhcp"	  #
[ -n $(echo $lib | grep yum) ] || install_command="yum install -y dnsmasq tftp-server syslinux dhcp-server"	  #
###################################################################################################################

# Creating tftp folder
sudo mkdir -p /var/tftpboot/pxelinux.cfg/
# Creating boot menu
sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')/pxelinux_menu.txt /var/tftpboot/pxelinux.cfg/default 

################ Get needed library and put it in tftp folder ###########################################
cd /													#
path_lib=$(locate pxelinux.0 | grep -E /pxelinux.0$ | sed 's/\/pxelinux.0//g' )				#
cp $(echo $path_lib)/{pxelinux.0,vesamenu.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot/	#
#########################################################################################################

#cd /var/lib/tftpboot/
#sudo cp /usr/lib/PXELINUX/pxelinux.cfg .
#sudo cp /usr/lib/syslinux/memdisk .
#sudo cp /usr/lib/syslinux/modules/bios/* .
#sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old

################ Make the image available on the network ########
file_exten=$(echo $image | cut -d "." -f2)			#
sudo cp $image /var/tftpboot/netboot_image.$(echo $file_exten)  #
#################################################################
