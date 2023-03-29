#!/bin/bash

convert $1 -resize 512x512 -background 'rgba(0,0,0,0)' -gravity center -extent 512x512 sticker_logo.png
