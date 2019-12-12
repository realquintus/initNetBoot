#!/bin/bash
${1:?"Please indicate the name of the package manager (apt or pacman supported)."}
if [[ $1 = "apt" ]];then
	apt-get install isc-dhcp-server tftpd-hpa syslinux syslinux-efi pxelinux memtest86+ nfs-kernel-server
elif [[ $1 = "pacman" ]];then
	pacman -S tftp pxe syslinux dhcp
fi
# Creation des répertoires
mkdir -p /srv/tftp/boot/ /srv/tftp/bios/pxelinux.cfg/ /srv/tftp/efi32/pxelinux.cfg/ /srv/tftp/efi64/pxelinux.cfg/
# Liens vers le répertoire boot
cd /srv/tftp/bios && ln -s ../boot boot
cd /srv/tftp/efi32 && ln -s ../boot boot
cd /srv/tftp/efi64 && ln -s ../boot boot

cp /usr/lib/syslinux/modules/bios/* /srv/tftp/bios/
cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp/bios/
cp /boot/memtest86+.bin /srv/tftp/bios/

