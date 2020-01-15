#!/bin/bash
function work
{
    echo "Partitioning..."
    sgdisk -o $1
    sgdisk -n 1:0:+2G -n 2:0:+1G -n 3:0:+2G -n 4:0:+32M -n 5:0:+64M -n 6:0:+1M -n 7:0:+16M -n 8:0:+700M -n 9:0:0 -t 1:0700 $1
    sgdisk -c 1:hos_data -c 2:vendor -c 3:APP -c 4:LNX -c 5:SOS -c 6:DTB -c 7:MDA -c 8:CAC -c 9:UDA $1
    sgdisk -p $1
    echo "Formatting..."
    mkfs.vfat -F 32 "${1}1"
    mkfs.ext4 -F "${1}2"
    mkfs.ext4 -F "${1}3"
    mkfs.ext4 -F "${1}4"
    mkfs.ext4 -F "${1}5"
    mkfs.ext4 -F "${1}6"
    mkfs.ext4 -F "${1}7"
    mkfs.ext4 -F "${1}8"
    mkfs.ext4 -F "${1}9"
    echo "Hybrid MBR, no idea if this works..."
    sgdisk -h 1 $1
}

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
if [ -z "$1" ] ; then echo "Please supply drive like /dev/sdX" ; exit 1 ; fi

sgdisk -p $1

while true; do
    read -p "This will clear all data from this drive! Are you sure? (y or n) " yn
    case $yn in
        [Yy]* ) work $1; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done
