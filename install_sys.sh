#!/bin/bash

# Never run pacman -Sy on your system!
pacman -Sy dialog

timedatectl set-ntp true

dialog --defaultno --title "Are you sure?" --yesno \
    "This is laydros's arch linux install. \n\n\
    It will DESTROY EVERYTHING on one of your hard disks. \n\n\
    Don't say YES if you are not sure what you are doing! \n\n\
    Do you want to continue?" 15 60 || exit

# dialog uses stderr for variables becuase it is using stdout
# to display the dialog
dialog --no-cancel --inputbox "Enter a name for your computer." \
    10 60 2> comp

# Verify boot (UEFI or BIOS)
uefi=0
ls /sys/firmware/efi/efivars 2> /dev/null && uefi=1

devices_list=($(lsblk -d | awk '{print "/dev/" $1 " " $4 " on"}' \
    | grep -E 'sd|hd|vd|nvme|mmcblk'))

dialog --title "Choose your hard drive" --no-cancel --radiolist \
    "Where do you want to install your new system? \n\n\
    Select with SPACE, valid with ENTER. \n\n\
    WARNING: Everything will be DESTROYED on the hard disk!" \
    15 60 4 "${devices_list[@]}" 2> hd

hd=$(cat hd) && rm hd

default_size="8"
dialog --no-cancel --inputbox \
    "You need three partitions: Boot, Root, and Swap \n\
    The boot partition will be 1024M \n\
    The root partition will be the remaining of the hard disk \n\n\
    Enter below the desired partition size (in Gb) for the Swap. \n\n\
    If you don't enter anything, it will default to ${default_size}G. \n" \
    20 60 2> swap_size
    size=$(cat swap_size) && rm swap_size

    [[ $size =~ ^[0-9]+$ ]] || size=$default_size

dialog --no-cancel \
    -- title "!!! DELETE EVERYTHING !!!" \
    --menu "Choose the way you'll wipe the hard disk ($hd)" \
    15 60 4 \
    1 "Use dd (wipe all disk)" \
    2 "Use shred (slow & secure)" \
    3 "No need - my disk is empty" 2> eraser

hderaser=$(cat eraser); rm eraser

function eraseDisk() {
    case $1 in
        1) dd if=/dev/zero of="$hd" status=progress 2>&1 \
            | dialog \
            --title "formatting $hd..." \
            --progressbox --stdout 20 60 ;;
        2) shred -v "$hd" \
            | dialog \
            --title "Formatting $hd..." \
            --progressbox --stdout 20 60;;
        3) ;;
    esac
}

# eraseDisk "$hderaser"

boot_partition_type=1
[[ "$uefi" == 0 ]] && boot_partition_type=4


