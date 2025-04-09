#!/bin/bash

show_usage() {
    echo "Usage: filepath, username"
    exit 1
}

if [ -z "$1" ] || [ -z "$2" ]; then
    show_usage
fi

FILE_PATH="$1"
USER_NAME="$2"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' does not exist."
    exit 1
fi


send_message() {
  local message="$1"
  local response=""

  response=$(curl -s -H "Content-Type: application/json" \
       -d "{\"content\":\"$message\"}" \
       "$DISCORD_WEBHOOK" || echo "")
  
  if [ -z "$response" ]; then
    echo "Warning: Message may not have been sent successfully"
  else
    echo "Message sent: $message"
  fi

  return 0
}


METADATA=$(ffprobe -v error -show_entries format_tags=artist,title,album -of default=noprint_wrappers=1:nokey=0 "$FILE_PATH")
ARTIST=""
ALBUM=""
TITLE=""

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

MESSAGE="**$USER_NAME** uploaded a new song! 🔊\n**$ARTIST**  -  **$TITLE**  -  **$ALBUM**"


send_message "$MESSAGE"

