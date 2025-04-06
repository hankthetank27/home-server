#!/bin/bash

# Audio File Metadata Checker
# This script checks for the presence of artist, title, and album metadata in MP3 and FLAC files

show_usage() {
    echo "Usage: $0 <file_path>"
    echo "Checks for artist, title, and album metadata in .mp3, .aiff, .flac or .wav files"
    exit 1
}

if [ $# -ne 1 ]; then
    show_usage
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' does not exist."
    exit 1
fi

FILE_EXT="${FILE_PATH##*.}"
FILE_EXT=$(echo "$FILE_EXT" | tr '[:upper:]' '[:lower:]')

check_metadata() {
    if ! command -v ffprobe &> /dev/null; then
        echo "Error: ffprobe is not installed. Please install."
        exit 1
    fi

    METADATA=$(ffprobe -v error -show_entries format_tags=artist,title,album -of default=noprint_wrappers=1:nokey=0 "$FILE_PATH")
    ARTIST=""
    ALBUM=""
    TITLE=""
    MISSING=0

    while IFS= read -r line; do
      line_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
      value="${line#*=}"
      if [[ "$line_lower" == *"tag:artist="* ]] || [[ "$line_lower" == *"tag:artist="* ]]; then
        ARTIST="$value"
      elif [[ "$line_lower" == *"tag:album="* ]] || [[ "$line_lower" == *"tag:album="* ]]; then
        ALBUM="$value"
      elif [[ "$line_lower" == *"tag:title="* ]] || [[ "$line_lower" == *"tag:title="* ]]; then
        TITLE="$value"
      fi
    done <<< "$METADATA"

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
    
    if [ "$MISSING" -eq 1 ]; then
        echo "Warning: Some metadata is missing in this file."
        rm -f "$FILE_PATH"
        return 1
    else
        echo "All metadata present!"
        return 0
    fi
}


case "$FILE_EXT" in
    mp3)
        check_metadata
        ;;
    flac)
        check_metadata
        ;;
    aiff)
        check_metadata
        ;;
    aif)
        check_metadata
        ;;
    wav)
        check_metadata
        ;;
    *)
        echo "Error: Unsupported file format. Only .mp3, .aiff, .wav, and .flac files are supported."
        rm -f "$FILE_PATH"
        ;;
esac

exit 0
