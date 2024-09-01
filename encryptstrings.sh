#!/bin/bash

echo "Script started"

# Function to encrypt text between quotes in files using Base64 encoding
encrypt_strings() {
  local password="$1"
  find . -type f | while IFS= read -r file; do
    echo "Encrypting $file"
    while IFS= read -r line; do
      echo "Processing line: $line"
      encrypted=$(echo "$line" | sed -E "s/(['\"])([^'\"]*)(\1)/\1$(echo -n \2 | openssl enc -aes-256-cbc -a -salt -pass pass:$password)\3/g")
      echo "$encrypted" >> "$file.tmp";
    done < "$file"
    mv "$file.tmp" "$file"
  done
}

# Function to decrypt text between quotes in files using Base64 encoding
decrypt_strings() {
  local password="$1"
  find . -type f -not -path '*/\.git/*' -not -name "$(basename "$0")" | while IFS= read -r file; do
    echo "Decrypting $file"
    while IFS= read -r line; do
      decrypted=$(echo "$line" | sed -E "s/(['\"])([A-Za-z0-9+/=]+)(\1)/\1$(echo -n \2 | openssl enc -aes-256-cbc -d -a -pass pass:$password)\3/g")
      echo "$decrypted" >> "$file.tmp"
    done < "$file"
    mv "$file.tmp" "$file"
  done
}

# Parse command-line arguments
commit_message="Encrypted strings in files"
decrypt_only=false
no_sync=false
while getopts "m:dn" opt; do
  case $opt in
    m) commit_message="$OPTARG" ;;
    d) decrypt_only=true ;;
    n) no_sync=true ;;
    *) echo "Usage: $0 [-m commit_message] [-d] [-n]"; exit 1 ;;
  esac
done

# Prompt for the password without echoing it
echo "Enter the password for encryption/decryption:"
read -s password

# Check if the current directory is a Git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "No git repository found. Initializing..."
  git init
fi

echo "Processing files"
if $decrypt_only; then
  echo "Decrypting strings in files"
  # Decrypt strings recursively in the directory
  decrypt_strings "$password"
else
  echo "Encrypting strings in files"
  # Encrypt strings recursively in the directory
  encrypt_strings "$password"

  # Add changes to git
  git add . &>/dev/null

  # Commit changes with the provided or default message
  git commit -m "$commit_message"

  # Push changes to the remote repository
  if ! $no_sync; then
    echo "Pushing changes to the remote repository"
    git push &>/dev/null
  fi
fi

echo "Operation completed."
