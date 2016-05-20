#!/bin/bash
set -eu

rm -f frames.zip
zip -j -0 frames.zip ../a09?.png

curl -v --data-binary @frames.zip http://192.168.0.18:43187/encode -o frames.qmg

# rsync frames.qmg root@192.168.0.4:/system/media/bootsamsungloop.qmg
adb push frames.qmg /sdcard/frames.qmg
adb shell su -c 'mv /sdcard/frames.qmg /system/media/bootsamsung.qmg'
adb reboot
