#########################################################################
# File Name: build.sh
# Author: Sues
# mail: sumory.kaka@foxmail.com
# Created Time: Fri 25 Sep 2020 10:36:07 AM CST
# Version : 1.0
#########################################################################
#!/bin/bash
make ARCH=arm CROSS_COMPILE=arm-linux- -j30
