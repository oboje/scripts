#!/bin/sh

url=$1
time=$2
duration=$3
NOW=$(date +"%H-%M-%S_%m.%d")
filename=youtube_$duration_$NOW.mp3
audio_url=$(yt-dlp -x --audio-format mp3 -g $url)

# Calculate the end time by adding the duration to the start time
end_time=$((time + duration))

ffmpeg -ss $time -to $end_time -i "$audio_url" -vn -c:a libmp3lame -q:a 4 "$filename"
