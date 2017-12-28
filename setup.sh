#!/bin/bash 
#SETUP SCRIPTS FOR RASPIAN
#chmod u+x setup.sh will make the file executable for only owner

#list of general utilities without GUI
LITE=1 #0 for barebone raspbian, 1 for raspbian with desktop

SOFTWARE_GENERAL_REPO_NON_GUI=" doxygen xclip checkinstall lm-sensors cmake valgrind gcc clang llvm emacs build-essential htop net-tools gnome-keyring libsecret dos2unix ufw "

#list of software with GUI                        
SOFTWARE_WITH_GUI=" gksu terminator guake ddd evince synaptic psensor gufw "

#list of dropped app
SOFTWARE_DROPPED=" gitg"

#all tool chains and utilities
ARM_TOOLCHAIN="gdb-arm-none-eabi openocd qemu gcc-arm-none-eabi"
AVR_ARDUINO_TOOLCHAIN="arduino avrdude avr-libc simulavr"
FULL="$ARM_TOOLCHAIN $AVR_ARDUINO_TOOLCHAIN" 

#software not in current Ubuntu 16.04 repos
SOFTWARE_GENERAL_NONREPO="\nFoxit_Reader Visual_Studio_Code\nSophos Veeam\n Chrome Segger-JLink\n"

#Color Variables for output, chosen for best visibility
#Consult the Xterm 256 color charts for more code 
#format is \33 then <fg_bg_code>;5;<color code>m, 38 for foreground, 48 for background
RED='\33[38;5;0196m' 
CYAN='\033[38;5;087m' #for marking the being of a new sections 
YELLOW='\033[38;5;226m' #for error 
GREEN='\033[38;5;154m' #for general messages 
RESET='\033[0m' #for resetting the color 
set -e 
#-------------------------------------------------------------------------------
if [ -f ${HOME}/we_rebooted ]; then #check if we rebooted

printf "${GREEN}\n Reboot done, continuing the second part \n ${RESET}"
sudo userdel -r pi 
mkdir ${HOME}/Workspace #Workspace for Visual Stuio Code 
if [ $LITE -eq 1 ] ; then
    SOFTWARE_GENERAL_REPO="${SOFTWARE_GENERAL_REPO_NON_GUI}${SOFTWARE_WITH_GUI}"
else 
    SOFTWARE_GENERAL_REPO="${SOFTWARE_GENERAL_REPO_NON_GUI}"
fi

if sudo apt-get update\
&& sudo apt-get dist-upgrade\
&& sudo apt-get install ${SOFTWARE_GENERAL_REPO}
then
printf "\n ${YELLOW}Basic Setup Done\n ${RESET}"
else 
printf "\n ${YELLOW}Failed in Basic update and install\n ${RESET}"
exit 1 
fi 

if sudo ufw enable; then 
printf  "${GREEN}Firewall Enabled\n ${RESET}"
sleep 4 
else 
printf "\n ${YELLOW}Firewall failed to enable\n ${RESET}"
exit 1 
sleep 4
fi

printf "\n ${CYAN}--------DEV-TOOLS----------- ${RESET}"
printf "${CYAN}\n Basic Install is done, please select additional install options: \n ${RESET}"
printf  "${CYAN}1/Full 2/ARM 3/AVR 4/Exit${RESET}" 
read option

case $option in #handle options
    1) printf "${GREEN}\n installing $FULL\n ${RESET}" 
    if ! sudo apt-get install $FULL; then
    printf "${YELLOW}\n Failed to install full package\n ${RESET}" 
    exit 1
    fi;;
    2) printf "${GREEN}\n installing $ARM_TOOLCHAIN\n ${RESET}"
    if ! sudo apt-get install $ARM_TOOLCHAIN; then 
    printf "${YELLOW}\n Failed to install ARM toolchain\n ${RESET}" 
    exit 1
    fi ;;
    3) printf "\n ${GREEN}installing $AVR_ARDUINO_TOOLCHAIN\n ${RESET}"
    if ! sudo apt-get install $AVR_ARDUINO_TOOLCHAIN; then 
    printf "\n ${YELLOW}Failed to install AVR toolchain\n ${RESET}"
    exit 1
    fi ;;
    4) printf "\n ${GREEN}Exit\n ${RESET}";;
    *) printf  "${YELLOW}\nInvalid options\n ${RESET}"
        exit 1;;
esac

rm -f ${HOME}/we_rebooted

printf "\n ${CYAN} --------POST-INST-----------\n ${RESET}"
printf  " ${GREEN} Script successfully executed \nPlease install these additional software if needed ${RESET} ${SOFTWARE_GENERAL_NONREPO} ${RESET}" 
exit 0

#-------------------------------------------------------------------------------
else
printf "${GREEN}\n Not rebooted, executing the first part of setup script \n ${RESET}"
sudo passwd -l root #disable root access
cd
sudo mkdir /home/backup
sudo cp ${HOME}/.profile ${HOME}/.bashrc /home/backup

sudo groups pi >> /home/backup/pi_group #output a file with all the pi group 

GROUPS="$(groups pi | sed 's/pi : //; s/pi //; s/ /,/g')" 
printf "${GREEN}Please input user name, no space: ${RESET}"
read USER_NAME
sudo adduser ${USER_NAME} 
sudo usermod -a -G ${GROUPS}

su - ${USER_NAME}
cp /home/backup/.profile /home/background/.bashrc ${HOME}

touch ${HOME}/we_rebooted #create a file to mark that we rebooted

printf "${GREEN}First part done, commencing reboot in 5 seconds ${RESET}"

sleep 5

sudo reboot 

fi
