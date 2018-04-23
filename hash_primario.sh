ls /dev/block/mmcblk0p17 > /dev/null 
if [ $? -eq 0 ];
then 
	echo -e "\e[0;33m";
	cat /dev/block/mmcblk0p17 |  pipe_progress | md5sum
	echo -e "\e[0m";
else
	echo -e "\e[0;33m";
	cat /dev/block/mmcblk1p17 |  pipe_progress | md5sum
	echo -e "\e[0m";
fi;
exit
