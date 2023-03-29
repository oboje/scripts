#!/bin/bash

b=$(system_profiler SPPowerDataType)
amp=$(echo "$b" | grep 'Amperage (mA):' | cut -d ':' -f 2 | xargs)
volt=$(echo "$b" | grep 'Voltage (mV):' | cut -d ':' -f 2 | xargs)
power=$(($amp * $volt / 1000))
echo "$b" | grep --color=never -A 1 'Battery Information:'
echo "$b" | grep --color=never -A 1 'Amperage (mA)'
echo "      Total Power (mW): $power"
echo ""
echo "$b" | grep --color=never -A 99 'AC Charger Information:'
