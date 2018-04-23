#!/bin/bash
CONTROL=0


#PS1='\[$(tput setaf 1)(\t)$(tput sgr0)\][\u-\W]\$> '
while [ $CONTROL -eq 0 ] ; do
	cat /etc/mtab | grep media >> /dev/null
	adb devices | grep -v 'List of devices attached' | grep 'device$' >> /dev/null
	if [ $? -ne 0 ]; then
		CONTROL=0
		echo "nada"
		sleep 5
	else
		CONTROL=0
		echo "volcando"
		adb shell 'busybox' | grep 'copyright' 
		if [ $? -ne 0 ]; then
			if [! -f busybox ]; then 
				wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-armv8l
				mv busybox-armv8l busybox
			fi
			adb root
			adb remount
			adb push busybox /storage/sdcard0/Documents
			adb shell < trasferencia_busybox.sh &
			echo "instalando busybox"
			sleep 5
		fi
		adb shell 'busybox' | grep 'copyright' 
		if [ $? -ne 0 ]; then echo "no se pudo instalar busybox"; else
			echo 'hash md5 - Comienzo `date +"%x - %X"`'
			adb shell su < "hash_primario.sh" 
			echo "hash md5 - Finalización `date +"%x - %X"`"
			
			#echo 'Volcano de imagen - Comienzo `date +"%x - %X"`'
			
			adb forward tcp:8888 tcp:8888
			adb shell su < trasferencia_imagen.sh >> /dev/null &
			sleep 5
			nc 127.0.0.1 8888 | bar | cat > device_image.dd
			
			#echo "volcado - Finalización `date +"%x - %X"`"
					
		fi
		
		echo -e "\e[0;33m" 
		md5sum device_image.dd  
		echo -e "\e[0m" 
		
		echo -e 'Así se escribe \e[1;34mG\e[0m\e[1;31mo\e[0m\e[1;33mo\e[0m\e[1;34mg\e[0m\e[1;32ml\e[0m\e[1;31me\e[0m'
		photorec /debug /log /d ./recuperados /cmd device_image.dd partition_none,options,mode_ext2,fileopt,everything,enable,search^C

		read -n 1 -s -r -p 'Press any key to continue';
	fi
done
exit 0
