#!/bin/bash

output=$(system_profiler SPPowerDataType)

# Parse needed information and handle missing data gracefully
amp=$(echo "$output" | grep 'Amperage (mA):' | cut -d ':' -f 2 | xargs || echo "N/A")
volt=$(echo "$output" | grep 'Voltage (mV):' | cut -d ':' -f 2 | xargs || echo "N/A")

# Check if amp and volt are numeric before attempting calculation
if [[ $amp =~ ^-?[0-9]+$ ]] && [[ $volt =~ ^-?[0-9]+$ ]]; then
    power=$(echo "scale=2; $amp * $volt / 1000" | bc)
else
    power="N/A"
fi

# Print out the information
echo "Battery Information:"
echo "  Amperage (mA): $amp"
echo "  Voltage (mV): $volt"
echo "  Total Power (mW): $power"
echo ""

echo "AC Charger Information:"
echo "$output" | grep --color=never -A 99 'AC Charger Information:'
