su
cp /storage/sdcard0/Documents/busybox /system/xbin/
rm /storage/sdcard0/Documents/busybox
chmod 555 /system/xbin/busybox 

#'cd /system/bin; chmod 555 busybox; for x in `./busybox --list`; do ln -s ./busybox $x; done'			
