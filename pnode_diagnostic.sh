#!/bin/bash

# Check if the script is run with sudo permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo permissions."
   exit 1
fi

### Colors ##
ESC=$(printf '\033')
RESET="${ESC}[0m"
BLACK="${ESC}[30m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"
DEFAULT="${ESC}[39m"

### Color Functions ##
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }
fn_bye() { exit 0; }
fn_fail() { echo "Wrong Option"; exit 1; }

greenprint '
 ██╗███╗░░██╗░█████╗░░█████╗░░██████╗░███╗░░██╗██╗████████╗░█████╗░░░░░█████╗░██████╗░░██████╗░
 ██║████╗░██║██╔══██╗██╔══██╗██╔════╝░████╗░██║██║╚══██╔══╝██╔══██╗░░░██╔══██╗██╔══██╗██╔════╝░
 ██║██╔██╗██║██║░░╚═╝██║░░██║██║░░██╗░██╔██╗██║██║░░░██║░░░██║░░██║░░░██║░░██║██████╔╝██║░░██╗░
 ██║██║╚████║██║░░██╗██║░░██║██║░░╚██╗██║╚████║██║░░░██║░░░██║░░██║░░░██║░░██║██╔══██╗██║░░╚██╗
 ██║██║░╚███║╚█████╔╝╚█████╔╝╚██████╔╝██║░╚███║██║░░░██║░░░╚█████╔╝██╗╚█████╔╝██║░░██║╚██████╔╝
 ╚═╝╚═╝░░╚══╝░╚════╝░░╚════╝░░╚═════╝░╚═╝░░╚══╝╚═╝░░░╚═╝░░░░╚════╝░╚═╝░╚════╝░╚═╝░░╚═╝░╚═════╝░



               _   _           _        _____  _                             _   _
              | \ | |         | |      |  __ \(_)                           | | (_)
         _ __ |  \| | ___   __| | ___  | |  | |_  __ _  __ _ _ __   ___  ___| |_ _  ___
        |  _ \|     |/ _ \ / _  |/ _ \ | |  | | |/ _  |/ _  |  _ \ / _ \/ __| __| |/ __|
        | |_) | |\  | (_) | (_| |  __/ | |__| | | (_| | (_| | | | | (_) \__ \ |_| | (__
        |  __/|_| \_|\___/ \____|\___| |_____/|_|\__ _|\__, |_| |_|\___/|___/\__|_|\___|
        | |                                             __/ |
        |_|                                            |___/				version 1.0



Welcome to the pNode Diagnostic Script. This script will automagically download & install & run 
the following programs:

- Smartmontools 	- For testing SSD drives
- Memtester     	- For testing RAM memory
- Speedtest-cli 	- For checking connection speeds
- NCDU				- Checking file usage sizes
- Htop          	- Awesome overview tool
- PasteBinIt		- Program to upload diagnostic file
'

# Determine the main OS disk
MAIN_DISK=$(df / | grep '^/dev' | awk '{print $1}')

sleep 5

magentaprint 'Creating Diagnostic File...'
sudo touch /home/nuc/pnode_diagnostic
sleep 3
yellowprint 'Stopping inc_mainnet Docker Container...'
sudo docker stop inc_mainnet
yellowprint 'Stopping pNode Supervisor Service...'
sudo service supervisor stop
sleep 3
magentaprint 'Updating apt'
sudo apt update &> /dev/null
sleep 3
magentaprint 'Installing Smartmontools, Memtester, Htop, Speedtest-cli, NCDU, PasteBinIt'
sudo apt install smartmontools memtester htop speedtest-cli ncdu pastebinit -y &> /dev/null
sleep 3

magentaprint 'Starting SSD test'
sudo smartctl -t long $MAIN_DISK
sleep 3

magentaprint 'Testing pNode RAM for Issues...'
sudo memtester 2048 1 >> /home/nuc/pnode_diagnostic
sleep 3
magentaprint 'Checking Connection Speeds'
sudo speedtest-cli >> /home/nuc/pnode_diagnostic
yellowprint 'Removing IP address from log output'
sudo sed -i '/^Testing from/d' pnode_diagnostic
yellowprint 'Removing other identifiable information'
sudo sed -i '/^Hosted by/d' pnode_diagnostic
sleep 3

magentaprint '10 minutes remaining...'
sleep 60
magentaprint '9 minutes remaining...'
sleep 60
magentaprint '8 minutes remaining...'
sleep 60
magentaprint '7 minutes remaining...'
sleep 60
magentaprint '6 minutes remaining...'
sleep 60
magentaprint '5 minutes remaining...'
sleep 60
magentaprint '4 minutes remaining...'
sleep 60
magentaprint '3 minutes remaining...'
sleep 60
magentaprint '2 minutes remaining...'
sleep 60
magentaprint '1 minutes remaining...'
sleep 60
greenprint 'Test Complete! 🥳'
sudo smartctl -l selftest $MAIN_DISK >> /home/nuc/pnode_diagnostic

greenprint 'Starting inc_mainnet Docker Container...'
sudo docker start inc_mainnet
greenprint 'Starting pNode Supervisor Service...'
sudo service supervisor start

magentaprint 'Uploading pnode_diagnostic'
sudo pastebinit -i /home/nuc/pnode_diagnostic
greenprint 'Copy the above link and provide to Incognito pNode Team: we.incognito.org/g/Support'
