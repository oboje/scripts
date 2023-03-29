#!/bin/bash

output="stickers"
mkdir $output
convert './stickers/*.*' -resize 512x512 -background 'rgba(0,0,0,0)' -gravity center -extent 512x512 $output/sticker%04d.png
