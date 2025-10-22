#!/bin/bash
set -e
# Compare two base64-encoded strings and show the diff

# Check for input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <base64_string1> <base64_string2>"
    exit 1
fi

# Read the base64-encoded strings
BASE64_1="$1"
BASE64_2="$2"

# Create temporary files
TMP1=$(mktemp)
TMP2=$(mktemp)

# Decode the base64 strings into temp files
echo "$BASE64_1" | base64 --decode > "$TMP1"
echo "$BASE64_2" | base64 --decode > "$TMP2"

# Compare the decoded files
echo "Comparing decoded contents..."
diff -u "$TMP1" "$TMP2"

# Clean up
rm -f "$TMP1" "$TMP2"