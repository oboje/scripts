#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Assign input file name from script argument
INPUT_FILE="$1"

# Generate output file name by replacing the file extension with .webm
OUTPUT_FILE="${INPUT_FILE%.*}.webm"

# FFmpeg command using input and output variables
ffmpeg \
    -i "${INPUT_FILE}" \
    -t 2.9 \
    -an \
    -filter_complex "\
[0:v]crop=ih:ih[video square];\
[video square]split=3[black canvas][white canvas][video square];\
[black canvas]setsar=1:1,drawbox=color=black@1:t=fill[black background];\
[white canvas]scale=w=iw*2:h=iw*2,format=yuva444p,geq=lum='p(X,Y)':a='st(1,pow(min(W/2,H/2),2))+st(3,pow(X-(W/2),2)+pow(Y-(H/2),2));if(lte(ld(3),ld(1)),255,0)',drawbox=color=white@1:t=fill[scaled up white circle];\
[scaled up white circle]scale=w=iw/2:h=iw/2[white circle];\
[black background][white circle]overlay=x=0:y=0[alpha mask];\
[video square][alpha mask]alphamerge,\
scale=512:512" \
    -filter_complex_threads 1 \
    -c:v libvpx-vp9 -auto-alt-ref 0 \
    -preset ultrafast \
    -pix_fmt yuva420p \
    "${OUTPUT_FILE}"

echo "Processing complete. Output saved to ${OUTPUT_FILE}"
