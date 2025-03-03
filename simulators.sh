#!/bin/bash

# Function to create a simulator
create_simulator() {
    local lang=$1
    local ios_version=$2
    local device_name="iPhone 16 Pro Max ($lang)"
    
    # Convert version number to runtime identifier format (e.g., 17.2 -> 17-2)
    local runtime_version=$(echo $ios_version | tr '.' '-')
    local udid=$(xcrun simctl create "$device_name" com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max com.apple.CoreSimulator.SimRuntime.iOS-$runtime_version)
    if [ $? -ne 0 ] || [ -z "$udid" ]; then
        echo "Failed to create simulator for $lang"
        return 1
    fi
    echo $udid
}

# Function to validate iOS version
validate_ios_version() {
    local ios_version=$1
    echo "Checking available iOS runtimes..."
    
    # Get available runtimes with their full identifiers
    local available_runtimes=$(xcrun simctl list runtimes | grep -E "iOS.*[0-9]+\.[0-9]+" || true)
    
    if [ -z "$available_runtimes" ]; then
        echo "No iOS runtimes found. Please install iOS runtimes from Xcode."
        return 1
    fi
    
    echo "Available iOS runtimes:"
    echo "$available_runtimes"
    
    # Convert version number to runtime identifier format (e.g., 17.2 -> 17-2)
    local runtime_version=$(echo $ios_version | tr '.' '-')
    
    # Check if the requested version exists
    if echo "$available_runtimes" | grep -q "iOS-$runtime_version"; then
        echo "iOS $ios_version runtime is available."
        return 0
    else
        echo "iOS version $ios_version is not available. Please use one of the available versions listed above."
        return 1
    fi
}

# Function to set language for a simulator
set_simulator_language() {
    local udid=$1
    local lang=$2
    local locale=$3

    xcrun simctl boot $udid
    if [ $? -ne 0 ]; then
        echo "Failed to boot simulator $udid"
        return 1
    fi
    
    # Wait a bit for the simulator to fully boot and create preference files
    sleep 2
    
    # Properly format JSON array for language setting
    plutil -replace AppleLanguages -json "[\"$lang\"]" ~/Library/Developer/CoreSimulator/Devices/$udid/data/Library/Preferences/.GlobalPreferences.plist
    if [ $? -ne 0 ]; then
        echo "Failed to set language for simulator $udid"
        return 1
    fi
    
    plutil -replace AppleLocale -string "$locale" ~/Library/Developer/CoreSimulator/Devices/$udid/data/Library/Preferences/.GlobalPreferences.plist
    if [ $? -ne 0 ]; then
        echo "Failed to set locale for simulator $udid"
        return 1
    fi
    
    xcrun simctl shutdown $udid
    sleep 1
    xcrun simctl boot $udid
    if [ $? -ne 0 ]; then
        echo "Failed to reboot simulator $udid"
        return 1
    fi
    # Final shutdown to keep system resources free
    sleep 1
    xcrun simctl shutdown $udid
}

# Function to create simulators for all languages
create_all_simulators() {
    local ios_version=$1
    local languages=("ar" "zh-Hans" "zh-Hant" "fr" "de" "id" "ja" "ko" "pt-BR" "ru" "es" "tr" "uk" "fa")
    local failed_langs=()
    
    echo "Creating simulators for all supported languages..."
    for lang in "${languages[@]}"; do
        echo "Creating simulator for language: $lang"
        case $lang in
            "ar")
                udid=$(create_simulator "Arabic" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "ar" "ar_SA"
                else
                    failed_langs+=("Arabic")
                    continue
                fi
                ;;
            "zh-Hans")
                udid=$(create_simulator "Chinese Simplified" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "zh-Hans" "zh_CN"
                else
                    failed_langs+=("Chinese Simplified")
                    continue
                fi
                ;;
            "zh-Hant")
                udid=$(create_simulator "Chinese Traditional" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "zh-Hant" "zh_TW"
                else
                    failed_langs+=("Chinese Traditional")
                    continue
                fi
                ;;
            "fr")
                udid=$(create_simulator "French" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "fr" "fr_FR"
                else
                    failed_langs+=("French")
                    continue
                fi
                ;;
            "de")
                udid=$(create_simulator "German" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "de" "de_DE"
                else
                    failed_langs+=("German")
                    continue
                fi
                ;;
            "id")
                udid=$(create_simulator "Indonesian" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "id" "id_ID"
                else
                    failed_langs+=("Indonesian")
                    continue
                fi
                ;;
            "ja")
                udid=$(create_simulator "Japanese" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "ja" "ja_JP"
                else
                    failed_langs+=("Japanese")
                    continue
                fi
                ;;
            "ko")
                udid=$(create_simulator "Korean" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "ko" "ko_KR"
                else
                    failed_langs+=("Korean")
                    continue
                fi
                ;;
            "pt-BR")
                udid=$(create_simulator "Portuguese (Brazil)" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "pt-BR" "pt_BR"
                else
                    failed_langs+=("Portuguese (Brazil)")
                    continue
                fi
                ;;
            "ru")
                udid=$(create_simulator "Russian" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "ru" "ru_RU"
                else
                    failed_langs+=("Russian")
                    continue
                fi
                ;;
            "es")
                udid=$(create_simulator "Spanish" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "es" "es_ES"
                else
                    failed_langs+=("Spanish")
                    continue
                fi
                ;;
            "tr")
                udid=$(create_simulator "Turkish" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "tr" "tr_TR"
                else
                    failed_langs+=("Turkish")
                    continue
                fi
                ;;
            "uk")
                udid=$(create_simulator "Ukrainian" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "uk" "uk_UA"
                else
                    failed_langs+=("Ukrainian")
                    continue
                fi
                ;;
            "fa")
                udid=$(create_simulator "Persian" $ios_version)
                if [ $? -eq 0 ]; then
                    set_simulator_language $udid "fa" "fa_IR"
                else
                    failed_langs+=("Persian")
                    continue
                fi
                ;;
        esac
        if [ $? -eq 0 ]; then
            echo "Created simulator for $lang with UDID: $udid"
        else
            failed_langs+=("$lang")
        fi
        echo "-------------------------------------------"
    done
    
    if [ ${#failed_langs[@]} -eq 0 ]; then
        echo "All simulators have been created successfully!"
    else
        echo "Warning: Failed to create simulators for the following languages:"
        printf '%s\n' "${failed_langs[@]}"
    fi
}

# Function to erase all simulators
erase_all_simulators() {
    xcrun simctl erase all
    if [ $? -eq 0 ]; then
        echo "All simulators have been erased."
    else
        echo "Failed to erase simulators."
        exit 1
    fi
}

# Main script logic
if [ "$1" == "eraseAll" ]; then
    erase_all_simulators
elif [ "$1" == "createAll" ] && [ $# -eq 2 ]; then
    ios_version=$2
    if ! validate_ios_version "$ios_version"; then
        exit 1
    fi
    create_all_simulators $ios_version
elif [ $# -eq 2 ]; then
    lang=$1
    ios_version=$2
    
    if ! validate_ios_version "$ios_version"; then
        exit 1
    fi

    case $lang in
    "ar")
        udid=$(create_simulator "Arabic" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "ar" "ar_SA"
        ;;
    "zh-Hans")
        udid=$(create_simulator "Chinese Simplified" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "zh-Hans" "zh_CN"
        ;;
    "zh-Hant")
        udid=$(create_simulator "Chinese Traditional" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "zh-Hant" "zh_TW"
        ;;
    "fr")
        udid=$(create_simulator "French" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "fr" "fr_FR"
        ;;
    "de")
        udid=$(create_simulator "German" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "de" "de_DE"
        ;;
    "id")
        udid=$(create_simulator "Indonesian" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "id" "id_ID"
        ;;
    "ja")
        udid=$(create_simulator "Japanese" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "ja" "ja_JP"
        ;;
    "ko")
        udid=$(create_simulator "Korean" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "ko" "ko_KR"
        ;;
    "pt-BR")
        udid=$(create_simulator "Portuguese (Brazil)" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "pt-BR" "pt_BR"
        ;;
    "ru")
        udid=$(create_simulator "Russian" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "ru" "ru_RU"
        ;;
    "es")
        udid=$(create_simulator "Spanish" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "es" "es_ES"
        ;;
    "tr")
        udid=$(create_simulator "Turkish" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "tr" "tr_TR"
        ;;
    "uk")
        udid=$(create_simulator "Ukrainian" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "uk" "uk_UA"
        ;;
    "fa")
        udid=$(create_simulator "Persian" $ios_version)
        [ $? -eq 0 ] && set_simulator_language $udid "fa" "fa_IR"
        ;;
    *)
        echo "Unsupported language. Supported languages are: ar, zh-Hans, zh-Hant, fr, de, id, ja, ko, pt-BR, ru, es, tr, uk, fa"
        exit 1
        ;;
    esac

    if [ $? -eq 0 ] && [ ! -z "$udid" ]; then
        echo "Simulator created with UDID: $udid"
    else
        echo "Failed to create or configure simulator"
        exit 1
    fi
else
    echo "Usage: $0 <language> <ios_version>"
    echo "   or: $0 eraseAll"
    echo "   or: $0 createAll <ios_version>"
    echo "Supported languages: ar, zh-Hans, zh-Hant, fr, de, id, ja, ko, pt-BR, ru, es, tr, uk, fa"
    echo "Example: $0 ar 17.5"
    echo "         $0 zh-Hans 17.5"
    echo "         $0 fr 17.5"
    echo "         $0 eraseAll"
    echo "         $0 createAll 17.5"
    exit 1
fi
