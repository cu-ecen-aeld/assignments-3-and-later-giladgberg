#!/bin/bash

# Check if both arguments are provided
if [ $# -ne 2 ]; then
  echo "Error: Two arguments required: <writefile> <writestr>"
  exit 1
fi

writefile=$1
writestr=$2

# Create parent directory if it doesn't exist
mkdir -p "$(dirname "$writefile")"

# Try to write to the file
if ! echo "$writestr" > "$writefile"; then
  echo "Error: Failed to create or write to '$writefile'"
  exit 1
fi

exit 0
