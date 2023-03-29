#!/bin/bash

DELAY=${DELAY:-10}
LOOP=${LOOP:-0}
r=$(realpath $1)
d=$(dirname $r)
pushd $d >/dev/null
f=$(basename $r)
n=$(webpinfo -summary $f | grep frames | sed -e 's/.* \([0-9]*\)$/\1/')
dur=$(webpinfo -summary $f | grep Duration | head -1 | sed -e 's/.* \([0-9]*\)$/\1/')

if (($dur > 0)); then
    DELAY = dur
fi

pfx=$(echo -n $f | sed -e 's/^\(.*\).webp$/\1/')
if [ -z $pfx ]; then
    pfx=$f
fi

echo "converting $n frames from $f
working dir $d
file stem '$pfx'"

for i in $(seq -f "%05g" 1 $n); do
    webpmux -get frame $i $f -o $pfx.$i.webp
    dwebp $pfx.$i.webp -o $pfx.$i.png
    exit
done

convert $pfx.*.png -delay $DELAY -loop $LOOP $pfx.gif
rm $pfx.[0-9]*.png $pfx.[0-9]*.webp
popd >/dev/null
