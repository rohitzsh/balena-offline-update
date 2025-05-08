#!/bin/sh

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
mkdir -p /run
mount -t tmpfs tmpfs /run

clear 
echo "starting process"
sleep 5 
echo "##################################"
echo "mounting usb disk"
if [ ! -f "/etc/fstab" ]; then
    echo "fstab not found"
else
    cat /etc/fstab
fi
mount -a
sleep 5

installer_disk=$(mount | grep /data | grep -oE \/dev\/[a-z]{1,})

clear
echo
echo
echo "##################################"
if [ ! -f "/data/disk.img" ]; then
    echo "   disk.img is missing, please mount the usb in your pc"
    echo "   and copy balena disk image to second partition and rename it as disk.img"
    echo 
    echo "   shutting down in 5 seconds"
    sleep 5
    umount /data
    sleep 1
    echo o > /proc/sysrq-trigger
fi

echo "    installer disk $installer_disk"
echo "    starting disk search"
echo

find /sys/block/ -type l | grep -vE 'loop|ram|sr0' | while IFS= read -r sysdev; do
  if [ "$(cat "$sysdev/removable")" -eq 0 ]; then
    disk="${sysdev##*/}"
    dev="/dev/$disk"
    if [ "$dev" = "$installer_disk" ]; then
        continue;
    fi
    clear
    echo
    echo "##################################"
    parted "$dev" print 2>/dev/null || true
    echo

    echo "checking for balena in $dev"
    mkdir /balena-boot
    if mount ${dev}1 /balena-boot; then
        sleep 1
        if [ -f "/balena-boot/config.json" ]; then
            echo "existing install, making a backup of config"
            cp /balena-boot/config.json /data
        else
            echo "$dev is not a balena device, creating fresh install"
        fi
        umount /balena-boot
    else
        echo "$dev is new disk, creating fresh install" 
    fi
    
    echo "flashing disk $dev"
    dd if=/data/disk.img of=${dev} bs=4096
    if [ -f "/data/config-force.json" ]; then
        echo "coping force config to disk $dev"
        mount ${dev}1 /balena-boot
        sleep 1
        cp /data/config-force.json /balena-boot/config.json
        umount /balena-boot
        rm /data/config.json
        echo "shutting down in 5 seconds"
        sleep 5
    elif [ -f "/data/config.json" ]; then
        echo "coping backup config to disk $dev"
        mount ${dev}1 /balena-boot
        sleep 1
        cp /data/config.json /balena-boot/config.json
        umount /balena-boot
        mv /data/config.json "/data/config-$(date -Is).json"
        echo "shutting down in 5 seconds"
        sleep 5
    fi
  fi
done

umount /data
sleep 1
echo o > /proc/sysrq-trigger

exec sh
