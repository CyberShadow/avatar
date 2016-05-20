#!/bin/bash
set -eux

rm -f bootanimation.zip
rm -rf frames/

mkdir frames
cp ../avatar-phoneboot?*.png frames/

WIDTH=$(identify -format "%w" frames/avatar-phoneboot000.png)
# convert -background none -resize "$WIDTH"x10000 label.svg label.png
inkscape --export-png  label.png -w "$WIDTH" -h $((WIDTH*160/240)) label.svg

(
	cd frames
	#mogrify -format jpg ./*.png
	#find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "mogrify -format jpg {}"
	#find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "mogrify -negate {}"
	find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "composite -gravity South ../label.png {} {}"
)

zip -0 -r bootanimation.zip desc.txt frames

adb push bootanimation.zip /sdcard/bootanimation.zip
adb shell su -c 'mv /sdcard/bootanimation.zip /system/media/bootanimation.zip'
adb shell su -c 'chmod 644 /system/media/bootanimation.zip'
adb reboot
