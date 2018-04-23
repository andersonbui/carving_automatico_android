ls /dev/block/mmcblk0p8 > /dev/null 
if [ $? -eq 0 ];
then 
	echo -e "\e[0;33m";
	cat /dev/block/mmcblk0p8 | busybox pipe_progress | md5sum
	echo -e "\e[0m";
else
	echo -e "\e[0;33m";
	cat /dev/block/mmcblk1p8 | busybox pipe_progress | md5sum
	echo -e "\e[0m";
fi;
exit
