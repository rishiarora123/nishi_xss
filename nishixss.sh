#!/bin/bash

# Default payload file
payload_file="nishi_xss.txt"

# Check if the user provided a URL file
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 -u <url_list_file>"
  echo "Payloads will be loaded from the default file: $payload_file"
  exit 1
fi

# Parse the command-line arguments
while getopts ":u:" opt; do
  case $opt in
    u) url_file="$OPTARG" ;;
    *) echo "Invalid option: -$OPTARG" && exit 1 ;;
  esac
done

# Verify the URL file exists
if [[ ! -f "$url_file" ]]; then
  echo "Error: File '$url_file' not found."
  exit 1
fi

# Verify the payload file exists
if [[ ! -f "$payload_file" ]]; then
  echo "Error: Payload file '$payload_file' not found."
  exit 1
fi

# Load payloads from the file
payloads=($(cat "$payload_file"))

# Process each URL in the file
while read -r url; do
  if [[ -z "$url" ]]; then
    continue
  fi

  echo "Testing URL: $url"
  
  for payload in "${payloads[@]}"; do
    # Inject payload into the query parameter "q"
    injected_url="${url}?q=${payload}"
    echo "  Checking with payload: $payload"

    # Send request with curl
    response=$(curl -s -o /dev/null -w "%{http_code}" "$injected_url")

    # Check the response code
    if [[ "$response" == "200" ]]; then
      echo "    [!] Possible XSS vulnerability detected with payload: $payload"
    else
      echo "    [-] No vulnerability detected (HTTP Status: $response)"
    fi
  done
done < "$url_file"
