#!/bin/bash
# Script to update DATA statements in install-nextp8.txt from a list of files
# Usage: ./update-data-from-zip.sh FILE_LIST [INSTALL_BAS_TXT]
# If FILE_LIST is "-" use stdin instead
# If INSTALL_BAS_TXT is not provided, defaults to install-nextp8.txt

set -e

FILE_LIST="${1:-}"
TARGETFILE="${2:-}"

if [ -z "$FILE_LIST" ]; then
    echo "Usage: $0 FILE_LIST [INSTALL_BAS_TXT]"
    echo "  FILE_LIST: path to file containing file list, or '-' for stdin"
    echo "  INSTALL_BAS_TXT: path to install-nextp8.txt (default: current dir)"
    exit 1
fi

SCRIPTDIR="$(dirname "$0")"

if [ -z "$TARGETFILE" ]; then
    TARGETFILE="$SCRIPTDIR/install-nextp8.txt"
fi

if [ ! -f "$TARGETFILE" ]; then
    echo "Error: $TARGETFILE not found"
    exit 1
fi

# Read file list from stdin or file
if [ "$FILE_LIST" = "-" ]; then
    FILES=$(cat)
else
    if [ ! -f "$FILE_LIST" ]; then
        echo "Error: $FILE_LIST not found"
        exit 1
    fi
    FILES=$(cat "$FILE_LIST")
fi

if [ -z "$FILES" ]; then
    echo "Error: No file list provided"
    exit 1
fi

# Create backup
cp "$TARGETFILE" "$TARGETFILE.bak"

# Find the line numbers for DATA sections using markers (dynamic detection)
DIR_START_MARKER=$(grep -n "^1250 REM DIRECTORIES_START" "$TARGETFILE.bak" | head -1 | cut -d: -f1)
DIR_COUNT_LINE=$(grep -n "^1260 DATA" "$TARGETFILE.bak" | head -1 | cut -d: -f1)
DIR_END_MARKER=$(grep -n "^1350 REM DIRECTORIES_END" "$TARGETFILE.bak" | head -1 | cut -d: -f1)
FILES_START_MARKER=$(grep -n "^1360 REM FILES_START" "$TARGETFILE.bak" | head -1 | cut -d: -f1)
FILES_END_MARKER=$(grep -n "^1520 REM FILES_END" "$TARGETFILE.bak" | head -1 | cut -d: -f1)
RESTORE_LINE=$(grep -n "^1530 RESTORE" "$TARGETFILE.bak" | head -1 | cut -d: -f1)

if [ -z "$DIR_START_MARKER" ] || [ -z "$RESTORE_LINE" ]; then
    echo "Error: Could not find DATA section markers in $TARGETFILE.bak"
    exit 1
fi

echo "Updating DATA sections"
echo "  Directories: lines $DIR_START_MARKER to $DIR_END_MARKER"
echo "  Files: lines $FILES_START_MARKER to $FILES_END_MARKER"
echo "  RESTORE: line $RESTORE_LINE"

# Count files from the provided list (no hardcoded file names)
FILE_COUNT=0
while IFS= read -r file; do
    if [ -n "$file" ]; then
        FILE_COUNT=$((FILE_COUNT + 1))
    fi
done <<< "$FILES"

# Extract directory paths from the existing BASIC file (lines between DIRECTORIES markers)
# Skip line with count (1260), extract DATA lines from 1270 onwards
DIR_COUNT=0
DIR_PATHS=()
while IFS= read -r line; do
    if [[ "$line" =~ ^[0-9]+[[:space:]]+DATA[[:space:]]+\"([^\"]+)\"[[:space:]]*$ ]]; then
        DIR_PATHS+=("${BASH_REMATCH[1]}")
    fi
done < <(sed -n "${DIR_START_MARKER},$((${DIR_END_MARKER}))p" "$TARGETFILE.bak")

DIR_COUNT=${#DIR_PATHS[@]}

# Build directory DATA section - read from existing file
{
    echo "${DIR_START_MARKER} REM DIRECTORIES_START"
    echo "${DIR_COUNT_LINE} DATA ${DIR_COUNT}"
    for i in "${!DIR_PATHS[@]}"; do
        echo "$((DIR_START_MARKER + 1 + i)) DATA \"${DIR_PATHS[$i]}\""
    done
    echo "${DIR_END_MARKER} REM DIRECTORIES_END"
} > /tmp/dir_data.txt

# Build file DATA section with dynamic line numbers
{
    echo "${FILES_START_MARKER} DATA ${FILE_COUNT}"
    line_num=${FILES_START_MARKER}
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            line_num=$((line_num + 10))
            echo "${line_num} DATA \"$file\""
        fi
    done <<< "$FILES"
    echo "${FILES_END_MARKER} REM FILES_END"
} > /tmp/file_data.txt

# Combine: everything before DIR_START_MARKER, new directories, new files, everything after RESTORE_LINE
head -n $((${DIR_START_MARKER} - 1)) "$TARGETFILE.bak" > "$TARGETFILE"
cat /tmp/dir_data.txt >> "$TARGETFILE"
cat /tmp/file_data.txt >> "$TARGETFILE"
tail -n +$((RESTORE_LINE)) "$TARGETFILE.bak" >> "$TARGETFILE"

rm -f /tmp/dir_data.txt /tmp/file_data.txt

echo "Updated $TARGETFILE"
echo "Files to install: $FILE_COUNT"
