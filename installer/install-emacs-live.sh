#!/bin/bash

# Emacs Live Installer
# Written by Sam Aaron samaaron@gmail.com
# May, 2012

# Note:
# Run at your own risk!
# As always, you should read code before you run it on your machine

# Directory to preserve any Emacs configs found
old_config=~/emacs-live-old-config
tmp_dir=~/.emacs-live-installer-tmp

# Borrowed from the lein downloader
HTTP_CLIENT=${HTTP_CLIENT:-"wget -O"}
if type -p curl >/dev/null 2>&1; then
    if [ "$https_proxy" != "" ]; then
        CURL_PROXY="-x $https_proxy"
    fi
    HTTP_CLIENT="curl $CURL_PROXY -f -L -o"
fi

if [[ -e $old_config ]]; then

  echo $(tput setaf 1)"Emacs Live Installer Warning"$(tput sgr0)

  echo "It looks like I've already stored an Emacs configuration in: "
  echo $(tput setaf 3)$old_config$(tput sgr0)
  echo "Please mv or rm it before running me again."
  echo "I don't want to clobber over valuable files."
  exit 0
fi

# Create temporary directory for working within
rm -rf $tmp_dir
mkdir $tmp_dir

# Download intro and outro text
$HTTP_CLIENT $tmp_dir/intro.txt https://raw.github.com/overtone/emacs-live/master/installer/intro.txt
$HTTP_CLIENT $tmp_dir/outro.txt https://raw.github.com/overtone/emacs-live/master/installer/outro.txt

# Print outro and ask for user confirmation to continue
echo ""
echo ""
echo $(tput setaf 4)
cat $tmp_dir/intro.txt
echo $(tput sgr0)
echo ""

read -p $(tput setaf 3)"Are you sure you would like to continue? (y/N) "$(tput sgr0)

if [[ $REPLY =~ ^[Yy]$ ]]; then

     # User wishes to install

     # Download Emacs Live as a zipball
     echo ""
     $HTTP_CLIENT $tmp_dir/live.zip https://github.com/overtone/emacs-live/zipball/master

     # Unzip zipball
     unzip $tmp_dir/live.zip -d $tmp_dir/

    created_old_emacs_config_dir=false

    function create_old_dir {
        if $created_old_emacs_config_dir; then
            # do nothing
            true
        else
            echo ""
            echo $(tput setaf 1)
            echo "Emacs config files detected. "
            echo "============================"
            echo ""
            echo $(tput sgr0)
            echo "These will be moved into the following dir for safekeeping"
            echo $old_config
            mkdir -p $old_config
            echo "# Your Old Emacs Config Files

This directory contains any Emacs configuration files that had existed prior
to installing Emacs Live.

To revert back to your old Emacs configs simply:

    rm -rf ~/.emacs.d
    mv $old_config_root/* ~/
    rmdir $old_config" > $old_config/README.md

            created_old_emacs_config_dir=true
        fi
    }

    echo ""
    echo ""

    if [ -e ~/.emacs.d/ ]; then
        create_old_dir
        echo $(tput setaf 1)
        echo "------------------------------------------"
        echo "Found ~/.emacs.d config directory"
        echo "Moving to $old_config/.emacs.d"
        echo ""
        mv ~/.emacs.d $old_config/.emacs.d
        echo "------------------------------------------"
        echo $(tput sgr0)
    fi

    if [ -e ~/.emacs.el ]; then
        create_old_dir
        echo $(tput setaf 1)
        echo "------------------------------------------"
        echo "Found ~/.emacs.el config file."
        echo "Moving to $old_config/.emacs.el"
        echo ""
        mv ~/.emacs.el $old_config/.emacs.el
        echo "------------------------------------------"
        echo $(tput sgr0)
    fi

    if [ -e ~/.emacs ]; then
        create_old_dir
        echo $(tput setaf 1)
        echo "------------------------------------------"
        echo "Found ~/.emacs config file."
        echo "Moving to $old_config/.emacs"
        echo ""
        mv ~/.emacs $old_config/.emacs
        echo "------------------------------------------"
        echo $(tput sgr0)
    fi

    mkdir ~/.emacs.d
    mv $tmp_dir/overtone*/* ~/.emacs.d

    echo ""
    echo ""
    echo $(tput setaf 5)
    cat $tmp_dir/outro.txt
    echo $(tput sgr0)
    echo ""

    rm -rf $tmp_dir

else
  echo "Installation aborted."
fi