#########################################################################
# File Name: do.sh
# Author: Sues
# mail: sumory.kaka@foxmail.com
# Created Time: Sun 27 Sep 2020 01:18:45 PM CST
# Version : 1.0
#########################################################################
#!/bin/bash

# usage : ./do.sh u-boot.bin zImage rootfs.tar.gz


if [ $# -eq 0 ];then
    echo usage : ./do.sh u-boot.bin zImage rootfs
    exit -2
fi

############################### STEP0 分区

#sd卡32G,62410752个sector
#    1. 512M 分区 (0-),用于zImage,fat16
#    2.      分区 (-62409165) ,用于rootfs,ext3
#    3. 剩余未分区(62409166-62410752),用于u-boot

# 62409166-62410752 排布

# |_________________|________|______________|______________|
# BL2(544个sector)  BL1(16)  signature(1)   Reserved(1025)

############################### STEP1 u-boot

boot=$1
zImage=$2
rootfs=$3

[ ! -e /dev/sdd ] && echo /dev/sdd not exist && exit -1

BYTES_PRE_SECTOR=512

let ALL_SECTOR_NUMBER=`sudo fdisk -l /dev/sdd | head -2 | tail -1 | awk -F " " '{print $7}'`
let Reserved_SECTOR_NUMBER=1025
let Signature_SECTOR_NUMBER=1
let BL1_SECTOR_NUMBER=16
let BL2_SECTOR_NUMBER=544

BL1_SECTOR_START_ADDR=`echo  ${ALL_SECTOR_NUMBER} - 1025 - 1 - 16 | bc`
BL2_SECTOR_START_ADDR=`echo ${BL1_SECTOR_START_ADDR} - ${BL2_SECTOR_NUMBER} | bc`

echo ALL_SECTOR_NUMBER     : ${ALL_SECTOR_NUMBER}
echo BL1_SECTOR_START_ADDR : ${BL1_SECTOR_START_ADDR}
echo BL2_SECTOR_START_ADDR : ${BL2_SECTOR_START_ADDR}


if [ -f ${boot} ];then
    rm ./bl1.bin ./bl2.bin -f
    sudo dd if=./${boot} of=./bl1.bin bs=${BYTES_PRE_SECTOR} count=${BL1_SECTOR_NUMBER}
    cp ./${boot} ./bl2.bin
fi


sudo dd if=./bl1.bin of=/dev/sdd seek=${BL1_SECTOR_START_ADDR} bs=${BYTES_PRE_SECTOR} count=${BL1_SECTOR_NUMBER}
sudo dd if=./bl2.bin of=/dev/sdd seek=${BL2_SECTOR_START_ADDR} bs=${BYTES_PRE_SECTOR} count=${BL2_SECTOR_NUMBER}


############################### STEP2 kernel

if [ -e /dev/sdd1 ];then
    echo COPY ${zImage}
    sudo mount  /dev/sdd1  /mnt
    sudo cp ${zImage} /mnt
    sudo umount /mnt
fi


############################### STEP2 rootfs

if [ -e /dev/sdd1 ] && [ -e $3 ];then
    echo COPY ${rootfs}
    sudo mount  /dev/sdd2  /mnt
    sudo rm /mnt/* -rf
    sudo tar xf  ${rootfs} -C /mnt
    sudo umount /mnt
fi
