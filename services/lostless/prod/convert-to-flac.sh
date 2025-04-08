#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_path>"
    exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
    echo "File does not exist: $FILE_PATH"
    exit 0
fi

FILE_EXT="${FILE_PATH##*.}"
FILE_EXT_LOWER=$(echo "$FILE_EXT" | tr '[:upper:]' '[:lower:]')

if [[ "$FILE_EXT_LOWER" != "wav" && "$FILE_EXT_LOWER" != "aiff" ]]; then
    exit 0
fi

DIR_PATH=$(dirname "$FILE_PATH")
FILE_NAME=$(basename "$FILE_PATH" ".$FILE_EXT")
OUTPUT_PATH="$DIR_PATH/$FILE_NAME.flac"

ffmpeg -i "$FILE_PATH" -c:a flac -compression_level 5 -map_metadata 0 "$OUTPUT_PATH"

if [ $? -eq 0 ] && [ -f "$OUTPUT_PATH" ]; then
    echo "Conversion successful: $OUTPUT_PATH"
    
    if [ -s "$OUTPUT_PATH" ]; then
        echo "Removing original file: $FILE_PATH"
        rm "$FILE_PATH"
        echo "Conversion complete!"
        exit 0
    else
        echo "Error: Output file is empty. Keeping original file."
        rm "$OUTPUT_PATH" 
        exit 1
    fi
else
    echo "Error: Conversion failed."
    # Clean up any partial output file
    if [ -f "$OUTPUT_PATH" ]; then
        rm "$OUTPUT_PATH"
    fi
    exit 1
fi
