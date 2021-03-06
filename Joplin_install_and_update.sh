#!/bin/bash
set -e
# Title
echo "     _             _ _       "
echo "    | | ___  _ __ | (_)_ __  "
echo " _  | |/ _ \| '_ \| | | '_ \ "
echo "| |_| | (_) | |_) | | | | | |"
echo " \___/ \___/| .__/|_|_|_| |_|"
echo "            |_|"
echo ""
echo "Linux Installer and Updater"

#-----------------------------------------------------
# Variables
#-----------------------------------------------------
COLOR_RED=`tput setaf 1`
COLOR_GREEN=`tput setaf 2`
COLOR_RESET=`tput sgr0`

# Check and warn if running as root.
if [[ $EUID = 0 ]] ; then
  if [[ $* != *--allow-root* ]] ; then
    echo "${COLOR_RED}It is not recommended (nor necessary) to run this script as root. To do so anyway, please use '--allow-root'${COLOR_RESET}"
    exit 1
  fi
fi

#-----------------------------------------------------
# Download Joplin
#-----------------------------------------------------

# Get the latest version to download
version=$(curl --silent "https://api.github.com/repos/laurent22/joplin/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")')

# Check if it's in the latest version
if [[ ! -e ~/.joplin/VERSION ]] || [[ $(< ~/.joplin/VERSION) != "$version" ]]; then

    echo 'Downloading Joplin...'
    # Delete previous version
    rm -f ~/.joplin/*.AppImage ~/.local/share/applications/joplin.desktop ~/.joplin/VERSION
    
    # Creates the folder where the binary will be stored
    mkdir -p ~/.joplin/
    
    # Download the latest version
    wget -nv --show-progress -O ~/.joplin/Joplin.AppImage https://github.com/laurent22/joplin/releases/download/v$version/Joplin-$version-x86_64.AppImage 
    
    # Gives execution privileges
    chmod +x ~/.joplin/Joplin.AppImage
    
    echo "${COLOR_GREEN}OK${COLOR_RESET}"
    
    #-----------------------------------------------------
    # Icon
    #-----------------------------------------------------
    
    # Download icon
    echo 'Downloading icon...'
    wget -nv -O ~/.joplin/Icon512.png https://joplin.cozic.net/images/Icon512.png
    echo "${COLOR_GREEN}OK${COLOR_RESET}"
    
    # Detect desktop environment  
    if [ "$XDG_CURRENT_DESKTOP" = "" ]
    then
      desktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(xfce\|kde\|gnome\).*/\1/')
    else
      desktop=$XDG_CURRENT_DESKTOP
    fi
    desktop=${desktop,,}  # convert to lower case

    # Create icon for Gnome
    echo 'Create Desktop icon.'
    if [[ $desktop =~ .*gnome.*|.*kde.*|.*xfce.*|.*mate.* ]]
    then
       echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=Joplin\nExec=/home/$USER/.joplin/Joplin.AppImage\nIcon=/home/$USER/.joplin/Icon512.png\nType=Application\nCategories=Application;" >> ~/.local/share/applications/joplin.desktop
       echo "${COLOR_GREEN}OK${COLOR_RESET}"
    else
       echo "${COLOR_RED}NOT DONE${COLOR_RESET}"
    fi
    
    #-----------------------------------------------------
    # Finish
    #-----------------------------------------------------
    
    # Informs the user that it has been installed and cleans variables
    echo "${COLOR_GREEN}Joplin version${COLOR_RESET}" $version "${COLOR_GREEN}installed.${COLOR_RESET}"
    # Add version
    echo $version > ~/.joplin/VERSION
else
    echo "${COLOR_GREEN}You already have the latest version${COLOR_RESET}" $version "${COLOR_GREEN}installed.${COLOR_RESET}"
fi
echo 'Bye!'
unset version
