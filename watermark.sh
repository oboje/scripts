#!/bin/bash

# Check if directory is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    echo "This script will process all PDF files in the specified directory"
    exit 1
fi

# Get absolute path of the directory
DIR_PATH=$(realpath "$1")

# Check if directory exists
if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory '$DIR_PATH' not found!"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v magick &>/dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    exit 1
fi

# Create output directory and temp directory structure
OUTPUT_DIR="${DIR_PATH}/watermarked"
TEMP_DIR="${OUTPUT_DIR}/temp"
mkdir -p "$TEMP_DIR"
WATERMARK_PATH="$TEMP_DIR/watermark_template.pdf"

# Create watermark template
create_watermark() {
    magick \
        -background none \
        -fill "rgba(128,128,128,0.2)" \
        -pointsize 20 \
        label:"CONFIDENTIAL for Sunline Real Estate" \
        -rotate 45 \
        +repage \
        +write mpr:TILE \
        +delete \
        -size 612x792 \
        xc:none \
        -alpha set \
        \( +clone \
        -fill mpr:TILE \
        -draw "color 0,0 reset" \
        \) \
        -composite \
        "$WATERMARK_PATH"
}

# Clear any existing temp files
rm -f "$TEMP_DIR"/*

# Create watermark template
echo "Creating watermark template..."
create_watermark

if [ ! -f "$WATERMARK_PATH" ]; then
    echo "Error: Failed to create watermark template!"
    exit 1
fi

# Counter for processed files
PROCESSED=0
ERRORS=0

# Find and process all PDF files in the directory
find "$DIR_PATH" -maxdepth 1 -type f -iname "*.pdf" | while read -r input_file; do
    # Skip files in the watermarked directory
    if [[ "$input_file" == *"/watermarked/"* ]]; then
        continue
    fi

    # Get just the filename without path
    filename=$(basename "$input_file")
    output_file="${OUTPUT_DIR}/${filename%.*}.pdf"

    echo "Processing: $filename"

    # Apply watermark using qpdf with absolute paths
    qpdf --overlay "$WATERMARK_PATH" \
        --repeat=1 \
        -- "$input_file" "$output_file"

    if [ $? -eq 0 ]; then
        echo "Created: $(basename "$output_file")"
        ((PROCESSED++))
    else
        echo "Error processing $filename"
        ((ERRORS++))
    fi
done

echo "Processing complete!"
echo "Files processed: $PROCESSED"
echo "Errors: $ERRORS"
echo "Watermarked files are in: $OUTPUT_DIR"
echo "Temporary files are in: $TEMP_DIR"
