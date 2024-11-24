#!/bin/bash

# Default payload file
payload_file="nishi_xss.txt"

# Check if URL is provided
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 -u <url>"
  echo "Payloads will be loaded from the default file: $payload_file"
  exit 1
fi

# Parse command-line arguments
while getopts ":u:" opt; do
  case $opt in
    u) url="$OPTARG" ;;
    *) echo "Invalid option: -$OPTARG" && exit 1 ;;
  esac
done

# Check if the payload file exists
if [[ ! -f "$payload_file" ]]; then
  echo "Error: Payload file '$payload_file' not found."
  exit 1
fi

# Load payloads from the file
payloads=($(cat "$payload_file"))

# Test the given URL with each payload
echo "Testing URL: $url"

for payload in "${payloads[@]}"; do
  # Construct the injected URL
  injected_url="${url}?q=${payload}"
  echo "  Checking with payload: $payload"

  # Send request and capture HTTP status code
  response=$(curl -s -o /dev/null -w "%{http_code}" "$injected_url")

  # Check the response code
  if [[ "$response" == "200" ]]; then
    echo "    [!] Possible XSS vulnerability detected with payload: $payload"
  else
    echo "    [-] No vulnerability detected (HTTP Status: $response)"
  fi
done
