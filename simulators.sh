#!/bin/bash

# Function to create a simulator
create_simulator() {
    local lang=$1
    local ios_version=$2
    local device_name="iPhone 15 ($lang)"
    local udid=$(xcrun simctl create "$device_name" com.apple.CoreSimulator.SimDeviceType.iPhone-15 com.apple.CoreSimulator.SimRuntime.iOS-$ios_version)
    echo $udid
}

# Function to set language for a simulator
set_simulator_language() {
    local udid=$1
    local lang=$2
    local locale=$3

    xcrun simctl boot $udid
    plutil -replace AppleLanguages -json "['$lang']" ~/Library/Developer/CoreSimulator/Devices/$udid/data/Library/Preferences/.GlobalPreferences.plist
    plutil -replace AppleLocale -string "$locale" ~/Library/Developer/CoreSimulator/Devices/$udid/data/Library/Preferences/.GlobalPreferences.plist
    xcrun simctl shutdown $udid
    xcrun simctl boot $udid
}

# Function to erase all simulators
erase_all_simulators() {
    xcrun simctl erase all
    echo "All simulators have been erased."
}

# Main script logic
if [ "$1" == "eraseAll" ]; then
    erase_all_simulators
elif [ $# -eq 2 ]; then
    lang=$1
    ios_version=$2

    case $lang in
    "ar")
        udid=$(create_simulator "Arabic" $ios_version)
        set_simulator_language $udid "ar" "ar_SA"
        ;;
    "uk")
        udid=$(create_simulator "Ukrainian" $ios_version)
        set_simulator_language $udid "uk" "uk_UA"
        ;;
    "en")
        udid=$(create_simulator "English" $ios_version)
        set_simulator_language $udid "en" "en_US"
        ;;
    *)
        echo "Unsupported language. Please use 'ar', 'uk', or 'en'."
        exit 1
        ;;
esac

    echo "Simulator created with UDID: $udid"
else
    echo "Usage: $0 <language> <ios_version>"
    echo "   or: $0 eraseAll"
    echo "Example: $0 ar 17.5"
    echo "         $0 uk 17.5"
    echo "         $0 en 17.5"
    echo "         $0 eraseAll"
    exit 1
fi
