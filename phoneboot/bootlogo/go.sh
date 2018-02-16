#!/bin/bash
set -eu

WIDTH=$(identify -format "%w" orig/logo.jpg)
#inkscape --export-png label.png -w "$WIDTH" -h $((WIDTH*160/240)) ../label.svg
convert -background none -density 1200 -resize "$WIDTH"x$((WIDTH*160/240)) ../label.svg label.png

rm -rf out
mkdir out

function edit() {
	composite -gravity South label.png "orig/$1" "out/$1"
}

edit logo.jpg
edit lpm.jpg
edit download.jpg
edit warning.jpg

for f in orig/*
do
	fn=$(basename "$f")
	if [[ ! -f "out/$fn" ]]
	then
		ln "$f" "out/$fn"
	fi
done

mapfile -t files < <(tar tf orig.img)

tar cvf out.tar \
	-C out \
	--owner dpi "${files[@]}" \
	--group dpi "${files[@]}"
cp --reflink=always --sparse=auto orig.img out.img
dd if=out.tar of=out.img conv=notrunc
