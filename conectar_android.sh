#!/bin/bash
CONTROL=0

function dump {
	#$1 ubicacion
	#$2 nombre distinguible
	#$3 nombre tabla
	nosamsung=$1
	existe=`echo -e "ls  $nosamsung \nexit" | adb shell su | grep 'No such file or directory' | wc -l`
	if [ $existe -eq 0 ]; then
		echo "existe $nosamsung" 
		echo "comenzando conexion"
		sleep 2
		# comenzando conexion
		echo `echo "cat $nosamsung | busybox nc -l -p 8888" | adb shell su ` &
		#adb shell su < trasferencia_registro.sh >> /dev/null &
		echo "inciando transferencia"
		sleep 4
		# inciando transferencia
		nc 127.0.0.1 8888 | bar | cat > $UBICACION_MUSB_CONECTADO"/"$2".db"
		echo "Desempaquetado..."; 
		sleep 2
		echo $registro1
		sqlite3  -header -csv $UBICACION_MUSB_CONECTADO"/"$2".db" "select $4 from "$3";" | cat > $UBICACION_MUSB_CONECTADO"/"$2".csv"
		echo "listo"; 
		sleep 2
		else echo "no existe el archivo $nosamsung";
	fi
}

#PS1='\[$(tput setaf 1)(\t)$(tput sgr0)\][\u-\W]\$> '
while [ $CONTROL -eq 0 ] ; do
	cat /etc/mtab | grep media >> /dev/null
	DISP_CONECTADO=`adb devices | grep -v 'List of devices attached' | grep 'device$' | wc -l`
	UBICACION_MUSB_CONECTADO=`cat /etc/mtab | grep media | grep -v loop | grep -v  sda |  awk '{ print  $2 }'`
	MUSB_CONECTADO_L=`cat /etc/mtab | grep media | grep -v loop | grep -v  sda |  awk '{ print  $2 }' | wc -l`
	# comprobar que un dispositivo de almacenamiento usb este conectado
	if [ $MUSB_CONECTADO_L -eq 0 ]; then
		echo -e "\e[0;31m usb no conectado \e[0m"; else echo "usb conectado"
	fi
	# comprobar que un dispositivo android este conectado
	if [ $DISP_CONECTADO -eq 0 ]; then
		echo -e "\e[0;31m android no conectado \e[0m"; else echo "android conectado";
	fi
	# mientras no este conectado ningun dispositivo
	if [ $DISP_CONECTADO -eq 0 ] || [ $MUSB_CONECTADO_L -eq 0 ]; then
		CONTROL=0
		echo "esperando..."
		sleep 5
	else
		# existe dispositivo android y almacenamiento usb conectado
		CONTROL=0
		echo "volcando"
		# comprobar que la herramiento busybox este presente en el dispositivo android
		adb shell 'busybox' | grep 'copyright' 
		# si no se encuentra entonces, instalarla en el dispositivo
		if [ $? -ne 0 ]; then
			# comprobar que se encuentre localmente en el equipo, de lo contrario, descargarla
			if [ ! -f busybox ]; then  
				# descarga
				wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-armv8l
				mv busybox-armv8l busybox
			fi
			# comienza instalacion
			adb root
			adb remount
			# enviar busybox
			adb push busybox /storage/sdcard0/Documents
			adb shell < trasferencia_busybox.sh &
			echo "instalando busybox"
			sleep 5
		fi
		# comprobar que la instalacion de busybox haya sido exitosa
		adb shell 'busybox' | grep 'copyright' 
		if [ $? -ne 0 ]; then echo "no se pudo instalar busybox"; else
			# calculo de hash del amacenamiento dentro del dispositivo movil
			echo 'hash md5 - Comienzo `date +"%x - %X"`'
			adb shell su < "hash_primario.sh" 
			echo "hash md5 - Finalización `date +"%x - %X"`"
			# crear comunicación con el dispositivo para transferencia de archivos
			adb forward tcp:8888 tcp:8888
			# comenzar transferencia de imagen de dispositivo
			adb shell su < trasferencia_imagen.sh >> /dev/null &
			sleep 5
			# almacenando imagen en equipo local
			nc 127.0.0.1 8888 | bar | cat > $UBICACION_MUSB_CONECTADO"/"device_image.dd
		
			echo -e "\e[0;33m" 
			# calculo de hash de la imagen local
			cat $UBICACION_MUSB_CONECTADO"/"device_image.dd |  bar | md5sum  
			echo -e "\e[0m" 
			
			# recuperacion de archivos borrados en la imagen
			#referencia: https://www.cgsecurity.org/wiki/Scripted_run#Command_list
			photorec /log /d $UBICACION_MUSB_CONECTADO"/"recuperados /cmd device_image.dd partition_none,options,mode_ext2,fileopt,everything,enable,search
			# obtener registro de llamadas
			
			# nombre de las bases de datos que se encuentran registros de llamadas mensajes y contactos del celular
			nosamsung="/data/data/com.android.providers.contacts/databases/contacts2.db";
			samsung="/data/data/com.sec.android.provider.logsprovider/databases/logs.db";
			
			# obtener bases de datos de registros para dispositivo samsung
			dump $nosamsung "contacts2" "calls" "_id, number,duration,name,date"
			# obtener bases de datos de registros para otros dispositivo  
			dump $samsung "logs" "logs" "_id, number,duration,name,date, messageid, m_content"
			
			
		fi
		# esperar ingreso de una tecla para volver a realizar todo el proceso anterior
		read -n 1 -s -r -p 'Press any key to continue';
	fi
done

exit 0
