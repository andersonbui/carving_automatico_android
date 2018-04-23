ls /dev/block/mmcblk0p17 >> /dev/null
if [ $? -eq 0 ]
then
	dd if='/dev/block/mmcblk0p17' | busybox nc -l -p 8888
else
	dd if='/dev/block/mmcblk1p17' | busybox nc -l -p 8888
fi
