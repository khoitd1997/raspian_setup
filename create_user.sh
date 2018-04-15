#!/bin/bash
# DON'T KEEP THIS FILE IN THE PI HOME DIR
RED='\33[38;5;0196m'
CYAN='\033[38;5;087m' #for marking the being of a new sections
YELLOW='\033[38;5;226m' #for error
GREEN='\033[38;5;154m' #for general messages
RESET='\033[0m' #for resetting the color

set -e

# change keyboard layout to make sure the rest of installation is correct
sudo sed -i '/XKBLAYOUT/d' /etc/default/keyboard
echo XKBLAYOUT=\"us\" | sudo tee /etc/default/keyboard


#Handle creating new users
GR="$(groups pi | sed 's/pi : //; s/pi //; s/ /,/g')"
printf "${GREEN}Please input user name, no space: ${RESET}"
read USER_NAME
sudo adduser ${USER_NAME}
sudo usermod -a -G ${GR} ${USER_NAME}


printf "${GREEN}Please enter the password of the new user\n ${RESET}"
su - ${USER_NAME}
cp /home/pi/.profile /home/pi/.bashrc ${HOME}

sudo passwd -l root #disable root access

# remove the default pi user
sudo killall -u pi
sudo deluser --remove-home pi
sudo groupdel pi

printf "${GREEN}\nDone Creating user and deleting pi user${RESET}"
