#!/bin/bash
usage(){
	echo -e "\e[1mInitNetBoot.sh\e[0m is a bash script that is used to initialize a network boot server using PXE.\nFirstly, it will install/update dependencies, then configure and enable DHCP and TFTP server.\n\t\e[1m\e[4mOptions:\e[0m\e[0m\n\t\t-h : Show this help message.\n\t\t-f : This option is needed and is used to indicate the image that you want to be available on the local network.\n\t\t-I : This option is required and is used to indicates the network interface through which the server will be available.\n\t\t-v : Verbose mode"
}

while getopts "f:vI:h" option;do
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
				srv_ip=$(ifconfig $interface | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sed -n 1p)
				if [ -z $srv_ip ];then
					echo "The specified network interface does not have an IP address."
					exit 3
				fi
			else
				echo "The specified network interface does not exist"
				exit 2
			fi
		;;
		h)
			usage
			exit 0
		;;
	esac
done

# Checking if every needed informations are specified
if [ -z $image ] || [ -z $interface ] || [ -z $srv_ip ];then
	echo "An information is missing, please read the following message:"
	usage
	exit 4
fi

# Checking if server is using UEFI, if not, it might cause problem like break your PC
[ -d /sys/firmware/efi ] && efi="true" || efi="false"

#################### Installing/updating dependencies ##########################################################################
lib=$(ls /var/lib/)												  	       #
[ -z $(echo $lib | grep apt) ] 2> /dev/null || install_command="apt install -y $(if [[ $verb = "true" ]];then;echo "-q";fi)dnsmasq syslinux-common"  		       #
[ -z $(echo $lib | grep pacman) ] 2> /dev/null || install_command="pacman -Sy  $(if [[ $verb = "true" ]];then;echo "-q";fi) --noconfirm dnsmasq syslinux"      	       #
[ -z $(echo $lib | grep yum) ] 2> /dev/null || install_command="yum install -y $(if [[ $verb = "true" ]];then;echo "-q";fi) dnsmasq syslinux"       			       #
if [[ $verb = "true" ]];then												       #
	echo "Installing needed packages: "$install_command										       #
else
	install_command="$install_command"" > /dev/null"
fi
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
														  #
if [[ $verb = "true" ]];then											  #
	echo "Copying needed  library un tftp folder..."							  #
fi														  #
path_lib=$(locate -e pxelinux.0 | grep -E /pxelinux.0$ | sed 's/\/pxelinux.0//g' )				  #
if [ -z $(ls /var/lib/tftpboot/ | grep pxelinux.0) ];then							  #
	cp -r $(echo $path_lib)/{pxelinux.0,vesamenu.c32,ldlinux.c32,libcom32.c32,libutil.c32} /var/lib/tftpboot/ #
fi														  #
###################################################################################################################

cd $(locate initNetBoot.sh | sed 's/initNetBoot.sh//g')
################ Make the image available on the network ############
if [[ $verb = "true" ]];then					    #
	echo "Copying netboot image on tftp folder..."		    #
fi								    #
file_exten=$(echo $image | awk -F "." '{print $NF}')		    #								    #
sudo cp $image /var/lib/tftpboot/netboot_image.$(echo $file_exten)  #
#####################################################################

### Configure dnsmasq ###
if [[ $verb = "true" ]];then
	echo "Configuring dnsmasq..."
fi
cat dnsmasq.conf | sed "s/%NIC%/$interface/g" | sed "s/%srv_addr%/$srv_ip/g" > /etc/dnsmasq.conf
