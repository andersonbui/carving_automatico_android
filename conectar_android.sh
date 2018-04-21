CONTROL=0
PLACE="./USBDRIVES"

#mkdir $PLACE
#chmod 777 -R $PLACE
while [ $CONTROL=0 ] ; do
	cat /etc/mtab | grep media >> /dev/null
	adb devices | grep 'device$' >> /dev/null
	if [ $? -ne 0 ]; then
		CONTROL=0
		echo "nada"
	else
		CONTROL=1
		echo "volcando"
		adb shell 'busybox' | grep 'copyright' 
		if [ $? -ne 0 ]; then
			adb push ./xbin/xbin/busybox /storage/sdcard0/Documents
			adb shell < trasferencia_busybox.sh &
			echo "instalando busybox"
		fi
		sleep 3
		adb forward tcp:8888 tcp:8888
		adb shell < ./trasferencia_imagen.sh  &
		sleep 2
		nc 127.0.0.1 8888 > device_image.dd
		read -n 1 -s -r -p "Press any key to continue".
		#exit 0
	fi
	sleep 5
done
exit 0
