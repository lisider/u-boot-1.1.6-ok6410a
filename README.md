# u-boot-1.1.6-ok6410a


烧写到ok6410 中 nand中的u-boot
source config.sh
source build.sh


烧写到ok6410 中 nand中的u-boot
source config.sh
source build.sh

然后cd 到 ok6410_sd, 执行脚本制作sd卡(前提为sd卡已经分区,且sd卡设备为/dev/sdd)
./do.sh u-boot.bin  zImage  rootfs-busybox.tar.gz

