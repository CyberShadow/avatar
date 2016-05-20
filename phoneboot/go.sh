#!/bin/bash
set -eux

rm -f bootanimation.zip
rm -rf frames/

mkdir frames
cp ../avatar?*.png frames/

(
	cd frames
	#mogrify -format jpg ./*.png
	#find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "mogrify -format jpg {}"
)

zip -0 -r bootanimation.zip desc.txt frames

adb push bootanimation.zip /sdcard/bootanimation.zip
adb shell su -c 'mv /sdcard/bootanimation.zip /system/media/bootanimation.zip'
adb shell su -c 'chmod 644 /system/media/bootanimation.zip'
adb reboot
