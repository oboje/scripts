#/bin/sh

time=$2
duration=$3
NOW=$(date +"%H-%M-%S_%m.%d")
filename=youtube_$duration_$NOW.mp4
ffmpeg $(youtube-dl -g $1 | sed "s/.*/-ss $time -i &/") -t $duration -c:a aac $filename
