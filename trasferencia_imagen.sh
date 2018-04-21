su
ls /dev/block/mmcblk1 2> /dev/null
if [ $? -ne 0 ]
then
	md5sum /dev/block/mmcblk0
	dd if="/dev/block/mmcblk0" | busybox nc -l -p 8888
else
	md5sum /dev/block/mmcblk1
	dd if="/dev/block/mmcblk1" | busybox nc -l -p 8888
fi
