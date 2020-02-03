#!/bin/bash

#################### Installing dependencies ######################################################################
lib=$(ls /var/lib/)												  #
[ -n $(echo $lib | grep apt) ] || install_command="apt install -y dnsmasq tftpd syslinux-common isc-dhcp-server"  #
[ -n $(echo $lib | grep pacman) ] || install_command="pacman -Sy --noconfirm dnsmasq tftp-hpa syslinux dhcp"	  #
[ -n $(echo $lib | grep yum) ] || install_command="yum install -y dnsmasq tftp-server syslinux dhcp-server"	  #
###################################################################################################################

# Creation des répertoires
sudo mkdir -p /var/tftpboot/pxelinux.cfg/
# Configuration
cd /var/tftpboot/
sudo cp /usr/lib/PXELINUX/pxelinux.cfg .
sudo cp /usr/lib/syslinux/memdisk .
sudo cp /usr/lib/syslinux/modules/bios/* .
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
