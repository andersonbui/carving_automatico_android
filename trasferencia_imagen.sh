su
ls /dev/block/mmcblk1 2> /dev/null
if [ $? -ne 0 ]
then
	dd if="/dev/block/mmcblk0" | busybox nc -l -p 8888
else
	dd if="/dev/block/mmcblk1" | busybox nc -l -p 8888
fi
