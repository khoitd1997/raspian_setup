#!/bin/bash

#list of general utilities without GUI
IS_EMBEDDED=0 #0 for barebone raspbian, 1 for raspbian with desktop

# Needed by both embedded and non embedded
SOFTWARE_UNIVERSAL=" checkinstall lm-sensors cmake gcc clang llvm build-essential htop net-tools gnome-keyring dos2unix ufw python3 python2"

# List of software for barebone embedded system
SOFTWARE_EMBEDDED_LINUX=" "

#list of software with GUI
SOFTWARE_WITH_GUI=" valgrind doxygen xclip gksu terminator guake ddd evince synaptic psensor gufw emacs "

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

# must not be pi or root to run this script
if [ ${USER} = pi ] || [ ${USER} = root ]; then
  echo "${GREEN}\nPlease create another user first and then run this script${RESET}\n"
  exit 1
fi

printf  "${GREEN}\nInstalling Universal Software\n${RESET}"

sudo apt-get update >> /dev/null
sudo apt-get dist-upgrade -y >> /dev/null
sudo apt-get install ${SOFTWARE_UNIVERSAL} -y >> /dev/null

if [ $IS_EMBEDDED -eq 1 ] ; then
    printf  "${GREEN}\nInstalling Software For GUI version\n${RESET}"
    sudo apt-get install ${SOFTWARE_WITH_GUI} -y >> /dev/null
    mkdir ${HOME}/Workspace #Workspace for Visual Stuio Code
else
    printf  "${GREEN}\nInstalling Software For Embedded version\n${RESET}"
    sudo apt-get install ${SOFTWARE_EMBEDDED_LINUX} -y >> /dev/null
fi

if sudo ufw enable ; then
printf  "${GREEN}Firewall Enabled\n ${RESET}"
else
printf "\n ${YELLOW}Firewall failed to enable\n ${RESET}"
exit 1
fi

if [ $IS_EMBEDDED -eq 1 ] ; then
printf "\n ${CYAN}--------DEV-TOOLS----------- ${RESET}"
printf "${GREEN}\n Basic Install is done, please select additional install options: \n ${RESET}"
printf  "${GREEN}1/Full 2/ARM 3/AVR 4/Exit${RESET}"
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
fi

printf "\n ${CYAN} --------POST-INST-----------\n ${RESET}"
if [ $IS_EMBEDDED -eq 1 ] ; then
printf  " ${GREEN} Script successfully executed \nPlease install these additional software if needed ${RESET} ${SOFTWARE_GENERAL_NONREPO} ${RESET}"
fi

printf  "${GREEN}\nRebooting in 5 seconds${RESET}"
sleep 5
reboot
