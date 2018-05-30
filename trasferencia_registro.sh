#ubicacion archivos  de https://www.andriller.com/decoders/
ls /data/data/com.sec.android.provider.logsprovider/databases/logs.db >> /dev/null
if [ $? -eq 0 ]
then
	cat /data/data/com.sec.android.provider.logsprovider/databases/logs.db | busybox nc -l -p 8888
else
	cat /data/data/com.android.providers.contacts/databases/contacts2.db | busybox nc -l -p 8888
fi

