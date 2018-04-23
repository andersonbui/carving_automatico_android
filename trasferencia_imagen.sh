ls /dev/block/mmcblk0p8 >> /dev/null
if [ $? -eq 0 ]
then
	dd if='/dev/block/mmcblk0p8' | busybox nc -l -p 8888
else
	dd if='/dev/block/mmcblk1p8' | busybox nc -l -p 8888
fi
