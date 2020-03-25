#!/bin/bash

# managing arguments
arg1=$1
arg2=$2
GREEN=`tput setaf 2`
RED=`tput setaf 1`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
RST=`tput sgr0`

if [[ $arg1 == "" || $arg2 == "" ]]
then
	cat <<EOF
Usage: $0 [OPTION]... (ip|name)
Initialize a new Hack the Box machine directory structure and perform initial
scans.
Options:
	arg1:		ip address of the box
	arg2:		name of the box
EOF
exit 1
fi

# Print an error message to stderr
function error {
	echo "[${RED}error${RST}] $@" 1>&2
}

# Print a warning message to stderr
function warning {
	echo "[${YELLOW}warning${RST}] $@" 1>&2
}

# Print some info to stdout
function info {
	echo "[${BLUE}info${RST}] $@"
}


# defining functions

## NMAP
info
nmap -sC -sV -oA ports $arg1
echo ""
echo ""
warning "Do you want to run the full port scan?[Y/n]"
read fullport
if [[ $fullport == "y" || $fullport == "" || $fullport == "Y" || $fullport == "yes" || $fullport == "Yes" ]]
then
	echo ""
	nmap -p- -oA fullport $arg1
else
	echo ""
fi

## Hostname
info "adding the hostname to /etc/hosts"
echo ""
echo "at what port is the http server at?[press enter for the port "${RED}80${RST}"]"
read port

warning "you may be prompted for sudo password to edit /etc/hosts"
if [[ $port == "80" || $port == ""]]
then
	echo $arg1"     "$arg2".htb" >> /etc/hosts
else
	echo $arg1":"$port"	"$arg2".htb" >> /etc/hosts
fi
echo ""
echo ""
info "open the ip using: "$arg2".htb"
url=${arg2}.htb

## gobuster
if [[ -n $(cat /etc/os-release |grep kali) ]]
then
	apt install gobuster
	gobuster dir -u http://${url}:${port}/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o dirbuster.root.out
else
	error "gobuster not installed / use a kali linux machine"
fi
	
