su
cp /storage/sdcard0/Documents/busybox /system/xbin/
rm /storage/sdcard0/Documents/busybox
cd /system/xbin
chmod 555 busybox; 
for x in `./busybox --list`
do 
    ln -s ./busybox $x;
done
