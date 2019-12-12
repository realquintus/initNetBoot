#!/bin/bash
${1:?"Please indicate the name of the package manager (apt or pacman supported)."}
if [[ $1 = "apt" ]];then
	apt-get install tftp pxe syslinux dhcp
elif [[ $1 = "pacman" ]];then
	pacman -S tftp pxe syslinux dhcp
fi
