#!/bin/bash
set -eux

DO_COMPOSE=1
DO_PNGOUT=1

rm -f bootanimation.zip

WIDTH=$(identify -format "%w" ../avatar-phoneboot000.png)
# convert -background none -resize "$WIDTH"x10000 label.svg label.png
inkscape --export-png  label.png -w "$WIDTH" -h $((WIDTH*160/240)) label.svg

zip -0 bootanimation.zip desc.txt

do_dir() {
	DIR="$1"
	MASK="$2"

	if [[ $DO_COMPOSE == 1 ]]
	then
		rm -rf "${DIR:?}"/

		mkdir "$DIR"
		cp ../$MASK "$DIR"/

		(
			cd "$DIR"
			#mogrify -format jpg ./*.png
			#find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "mogrify -format jpg {}"
			#find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "mogrify -negate {}"
			find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "composite -gravity South ../label.png {} {}"

			if [[ $DO_PNGOUT == 1 ]]
			then
				find -iname "*.png" -type f -print0 | parallel --progress -0 -j +0 "pngout {} -f0"
			fi
		)
	fi

	zip -0 -r bootanimation.zip "$DIR"
}

do_dir intro 'avatar-phoneboot-intro???.png'
do_dir loop 'avatar-phoneboot???.png'

while ! adb push bootanimation.zip /data/local/tmp/bootanimation.zip ; do sleep 1 ; echo Retrying... ; done
adb shell su -c "mount -o remount,rw /system"
adb shell su -c 'mv /data/local/tmp/bootanimation.zip /system/media/bootanimation.zip'
adb shell su -c 'chmod 644 /system/media/bootanimation.zip'
adb reboot
