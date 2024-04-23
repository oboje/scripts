#/bin/sh

# List all simulators
xcrun simctl list devices

# Shutdown all simulators except iPhone 17.5
for sim in $(xcrun simctl list devices | grep -v "iPhone 17.5" | grep -oE "([0-9A-F-]{36})"); do
    xcrun simctl shutdown $sim
done

# Remove all simulators except iPhone 17.5
for sim in $(xcrun simctl list devices | grep -v "iPhone 17.5" | grep -oE "([0-9A-F-]{36})"); do
    xcrun simctl delete $sim
done

# List devices again to confirm removal
xcrun simctl list devices
