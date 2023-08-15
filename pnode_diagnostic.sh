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
sudo touch /home/nuc/aos/pnode_diagnostic
sleep 3
magentaprint 'Updating apt'
sudo apt update &> /dev/null
sleep 3
magentaprint 'Installing Smartmontools, Memtester, Htop, Speedtest-cli, NCDU, PasteBinIt'
sudo apt install smartmontools memtester htop speedtest-cli ncdu pastebinit -y &> /dev/null
sleep 3

magentaprint 'Starting SSD'
sudo smartctl -t long $MAIN_DISK
sleep 3

# Get the estimated time for the long test
ESTIMATED_TIME=$(sudo smartctl -c $MAIN_DISK | grep "Extended self-test routine" | awk '{print $4}' | tr -d '[]')

# Loop to check the test status and calculate remaining time
while true; do
    # Get the percentage of the test that has been completed
    COMPLETED_PERCENT=$(sudo smartctl -c $MAIN_DISK | grep "Self-test execution status" | awk '{print $4}' | tr -d '()')

    # Calculate remaining time
    REMAINING_TIME=$((ESTIMATED_TIME * (100 - COMPLETED_PERCENT) / 100))

    # Break the loop if the test is completed
    if [[ $COMPLETED_PERCENT -eq 100 ]]; then
        break
    fi

    # Display the remaining time
    magentaprint "$REMAINING_TIME minutes remaining..."

    # Wait for a minute before checking again
    sleep 60
done

magentaprint 'Test Complete! 🥳'
sudo smartctl -l selftest $MAIN_DISK >> /home/nuc/aos/pnode_diagnostic

magentaprint 'Test pNode RAM for Issues'
sudo memtester 2048 1 >> /home/nuc/aos/pnode_diagnostic
sleep 3
magentaprint 'Checking Connection Speeds'
sudo speedtest-cli >> /home/nuc/aos/pnode_diagnostic
sudo sed -i '/^Testing from/d' filename.txt
sleep 3

magentaprint 'Uploading pnode_diagnostic'
sudo pastebinit -i /home/nuc/aos/pnode_diagnostic -b sprunge.us
magentaprint 'Copy the above link and provide to Incognito pNode Team: we.incognito.org/g/Support'
sleep 3
