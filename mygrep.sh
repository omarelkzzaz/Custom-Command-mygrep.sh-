#!/bin/bash

# Function to print usage/help
print_usage() {
  echo "Usage: $0 [OPTIONS] search_string filename"
  echo "Options:"
  echo "  -n    Show line numbers"
  echo "  -v    Invert match (show non-matching lines)"
  echo "  --help    Display this help message"
  exit 0
}

# Error handling: Check for --help
if [[ "$1" == "--help" ]]; then
  print_usage
fi

# Error handling: Too few arguments
if [[ $# -lt 2 ]]; then
  echo "Error: Not enough arguments."
  print_usage
fi

# Initialize options
show_line_numbers=false
invert_match=false

# Parse options
while [[ "$1" == -* ]]; do
  case "$1" in
    -n) show_line_numbers=true ;;
    -v) invert_match=true ;;
    -vn|-nv) 
      show_line_numbers=true
      invert_match=true
      ;;
    *) 
      echo "Error: Unknown option '$1'"
      print_usage
      ;;
  esac
  shift
done

# Now $1 is the search string, $2 is the filename
search_string="$1"
file="$2"

# Error handling: Missing search string or file
if [[ -z "$search_string" || -z "$file" ]]; then
  echo "Error: Missing search string or file."
  print_usage
fi

# Error handling: File does not exist
if [[ ! -f "$file" ]]; then
  echo "Error: File '$file' not found."
  exit 1
fi

# Main functionality
line_number=0
while IFS= read -r line; do
  ((line_number++))
  if [[ "$line" =~ $search_string ]]; then
    match=true
  else
    match=false
  fi
  
  # Case-insensitive
  if echo "$line" | grep -iq "$search_string"; then
    match=true
  else
    match=false
  fi

  if $invert_match; then
    match=$(! $match && echo true || echo false)
  fi

  if $match; then
    if $show_line_numbers; then
      echo "${line_number}:$line"
    else
      echo "$line"
    fi
  fi
done < "$file"
