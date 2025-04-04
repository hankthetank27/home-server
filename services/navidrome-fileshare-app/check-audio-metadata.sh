#!/bin/bash

# Audio File Metadata Checker
# This script checks for the presence of artist, title, and album metadata in MP3 and FLAC files

show_usage() {
    echo "Usage: $0 <file_path>"
    echo "Checks for artist, title, and album metadata in .mp3 or .flac files"
    exit 1
}

# Check if a file path was provided
if [ $# -ne 1 ]; then
    show_usage
fi

FILE_PATH="$1"

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' does not exist."
    exit 1
fi

FILE_EXT="${FILE_PATH##*.}"
FILE_EXT=$(echo "$FILE_EXT" | tr '[:upper:]' '[:lower:]')

check_mp3_metadata() {
    if ! command -v id3v2 &> /dev/null; then
        echo "Error: id3v2 is not installed. Please install."
        exit 1
    fi

    ID3_INFO=$(id3v2 -l "$FILE_PATH")
    ARTIST=$(echo "$ID3_INFO" | grep -i "TPE1" | cut -d ":" -f2- | sed 's/^[[:space:]]*//')
    TITLE=$(echo "$ID3_INFO" | grep -i "TIT2" | cut -d ":" -f2- | sed 's/^[[:space:]]*//')
    ALBUM=$(echo "$ID3_INFO" | grep -i "TALB" | cut -d ":" -f2- | sed 's/^[[:space:]]*//')
    MISSING=0
    
    echo "MP3 File: $FILE_PATH"
    echo "-------------------------"
    
    if [ -z "$ARTIST" ]; then
        echo "✗ Artist: Missing"
        MISSING=1
    else
        echo "✓ Artist: $ARTIST"
    fi
    
    if [ -z "$TITLE" ]; then
        echo "✗ Title: Missing"
        MISSING=1
    else
        echo "✓ Title: $TITLE"
    fi
    
    if [ -z "$ALBUM" ]; then
        echo "✗ Album: Missing"
        MISSING=1
    else
        echo "✓ Album: $ALBUM"
    fi
    
    echo "-------------------------"
    
    if [ $MISSING -eq 1 ]; then
        echo "Warning: Some metadata is missing in this MP3 file."
        rm -f "$FILE_PATH"
        return 1
    else
        echo "All metadata present!"
        return 0
    fi
}

check_flac_metadata() {
    if ! command -v metaflac &> /dev/null; then
        echo "Error: metaflac is not installed. Please install flac package."
        exit 1
    fi

    FLAC_INFO=$(metaflac --list --block-type=VORBIS_COMMENT "$FILE_PATH")
    ARTIST=$(echo "$FLAC_INFO" | grep -i "ARTIST=" | cut -d "=" -f2-)
    TITLE=$(echo "$FLAC_INFO" | grep -i "TITLE=" | cut -d "=" -f2-)
    ALBUM=$(echo "$FLAC_INFO" | grep -i "ALBUM=" | cut -d "=" -f2-)
    MISSING=0
    
    echo "FLAC File: $FILE_PATH"
    echo "-------------------------"
    
    if [ -z "$ARTIST" ]; then
        echo "✗ Artist: Missing"
        MISSING=1
    else
        echo "✓ Artist: $ARTIST"
    fi
    
    if [ -z "$TITLE" ]; then
        echo "✗ Title: Missing"
        MISSING=1
    else
        echo "✓ Title: $TITLE"
    fi
    
    if [ -z "$ALBUM" ]; then
        echo "✗ Album: Missing"
        MISSING=1
    else
        echo "✓ Album: $ALBUM"
    fi
    
    echo "-------------------------"
    
    if [ $MISSING -eq 1 ]; then
        echo "Warning: Some metadata is missing in this FLAC file."
        rm -f "$FILE_PATH"
        return 1
    else
        echo "All metadata present!"
        return 0
    fi
}

# Process the file based on its extension
case "$FILE_EXT" in
    mp3)
        check_mp3_metadata
        ;;
    flac)
        check_flac_metadata
        ;;
    *)
        echo "Error: Unsupported file format. Only .mp3 and .flac files are supported."
        rm -f "$FILE_PATH"
        ;;
esac

exit 0
