#!/bin/bash
${1:?"Please indicate the name of the package manager (apt or pacman supported)."}
if [[ $1 = "apt" ]];then
	apt-get install dnsmasq pxelinux syslinux-common
elif [[ $1 = "pacman" ]];then
	pacman -S dnsmasq mkpxelinux syslinux
fi
# Creation des répertoires
sudo mkdir -p /var/tftpboot/pxelinux.cfg/
# Configuration
cd /var/tftpboot/
sudo cp /usr/lib/PXELINUX/pxelinux.cfg .
sudo cp /usr/lib/syslinux/memdisk .
sudo cp /usr/lib/syslinux/modules/bios/* .
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old

