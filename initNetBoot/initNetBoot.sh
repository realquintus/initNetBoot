#!/bin/bash
usage(){
	echo -e "\e[1mInitNetBoot.sh\e[0m is a bash script that is used to initialize a network boot server using PXE.\nFirstly, it will install/update dependencies, then configure and enable DHCP and TFTP server.\n\t\e[1m\e[4mOptions:\e[0m\e[0m\n\t\t-h : Show this help message.\n\t\t-f : This option is needed and is used to indicate the image that you want to be available on the local network.\n\t\t-I : This option is required and is used to indicates the network interface through which the server will be available.\n\t\t-v : Verbose mode"
}
########################################## Handling options ############################################################
while getopts "f:vI:hN" option;do											#
	case $option in													#
		f)													#
			if [ -e $OPTARG ];then										#
				image=$OPTARG										#
			else												#
				echo -e "Error, file does not exist"							#
				usage											#
				exit 1											#
			fi												#
		;;													#
		v)													#
			verb="true"											#
		;;													#
		I)													#
			ip a s $OPTARG 2> /dev/null > /dev/null								#
			if [ $? -eq 0 ];then										#
				interface=$OPTARG									#
			else												#
				echo "The specified network interface does not exist"					#
				exit 2											#
			fi												#
		;;													#
		h)													#
			usage												#
			exit 0												#
		;;													#
		N)
			no_install="true"
		;;
	esac														#
done															#
#########################################################################################################################

############# Configuring network interface #############################################
if [ -z $(ifconfig $interface | sed -n '1p' | grep -o "UP") ];then			#	
	if [[ $verb = "true" ]];then							#
		echo "The interface is down, setting it up"				#
	fi										#
	ip link set up dev $interface							#
fi											#
srv_ip=$(ifconfig $interface | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sed -n 1p)	#
if ! [[ -z $srv_ip ]];then								#
	if [[ $verb = "true" ]];then							#
		echo "Flushing ip address on $interface"				#
	fi										#
	ip addr flush dev $interface;							#
fi											#
if [[ $verb = "true" ]];then								#
	echo "Adding ip address 192.168.55.254 on $interface"				#
fi											#
ip addr add 192.168.55.254/24 dev $interface						#
#########################################################################################

if [ -z $image ] || [ -z $interface ];then
	echo "An information is missing, please read the following message:"
	usage
	exit 4
fi

# Checking if server is using UEFI, if not, it might cause problem like break your bios
[ -d /sys/firmware/efi ] && efi="true" || efi="false"

#################### Installing/updating dependencies ###################################################################################################
lib="$(ls /var/lib/)"												  	       				#
if ! [ -z $(echo $lib | grep -o "apt") ];then														#
	install_command="apt install -y ""$(if [ -z $verb ];then echo '-q ';fi)""dnsmasq syslinux-common"  	  					#
elif ! [ -z $(echo $lib | grep -o "pacman") ];then													#
	install_command="pacman -Sy $(if [ -z $verb ];then echo '-q ';fi)--noconfirm dnsmasq syslinux" 							#
elif ! [ -z $(echo $lib | grep -o "yum") ];then														#
	install_command="yum install -y $(if [ -z $verb ];then echo '-q ';fi)dnsmasq syslinux"								#
else 																			#
	echo "Warning: Your package manager is not detected, make sure you have installed dnsmasq and syslinux (or syslinux-common)"			#
fi																			#
if [ -z $no_install ];then
	if [[ $verb = "true" ]];then												       				#
		echo -e "\n## Installing needed packages: $install_command ##"										      	#
	else																			#
		install_command="$install_command"" > /dev/null"												#
	fi																			#
	eval $install_command													       				#
	echo -e "## Installation finished ##\n"															#
fi
#########################################################################################################################################################

######## Creating tftp folder #################
if [[ $verb = "true" ]];then		      #
	echo "Creating tftp's folder"	      #
fi					      #
sudo mkdir -p /var/lib/tftpboot/pxelinux.cfg/ #
###############################################

###################### Creating boot menu ###############################################################
if [[ $verb = "true" ]];then										#
	echo "Loading boot menu in /var/lib/tftpboot/pxelinux.cfg"					#
fi													#
sudo cp $(echo $0 | sed 's/initNetBoot.sh//g')pxelinux_menu.txt /var/lib/tftpboot/pxelinux.cfg/default 	#
#########################################################################################################

################ Get needed library and put it in tftp folder #####################################################
														  #
if [[ $verb = "true" ]];then											  #
	echo "Copying needed library un tftp folder..."							  	  #
fi														  #
path_lib=$(locate -e pxelinux.0 | grep -E /pxelinux.0$ | sed 's/\/pxelinux.0//g' )				  #
if [ -z $(ls /var/lib/tftpboot/ | grep pxelinux.0) ];then							  #
	cp -r $(echo $path_lib)/{pxelinux.0,vesamenu.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot/ #
fi														  #
###################################################################################################################

#cd $(echo $0 | sed 's/initNetBoot.sh//g')
################ Make the image available on the network ############
if [[ $verb = "true" ]];then					    #
	echo "Copying netboot image on tftp folder..."		    #
fi								    #
#file_exten=$(echo $image | awk -F "." '{print $NF}')		    #
sudo cp -r $image /var/lib/tftpboot/				#
#####################################################################

########################### Configure dnsmasq ###########################################################
if [[ $verb = "true" ]];then									 	#
	echo "Configuring dnsmasq..."								 	#
fi												 	#
cat $(echo $0 | sed 's/initNetBoot.sh//g')dnsmasq.conf | sed "s/%NIC%/$interface/g" > /etc/dnsmasq.conf #
#########################################################################################################
