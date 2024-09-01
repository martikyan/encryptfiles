#!/bin/bash

echo "Script started"

encrypt_strings() {
  local password="$1"
  find . -type f -not -path '*/\.git/*' -not -name "$(basename "$0")" -not -name '*.sh' | while IFS= read -r file; do
    echo "Encrypting $file"
    
    # Create a temporary file to store the results
    > "$file.tmp"
  
    # Encrypt text inside single quotes
    
    # Replace the original file with the encrypted content
    mv "$file.tmp" "$file"
  done
}


# Function to decrypt text between quotes in files using Base64 decoding
decrypt_strings() {
  local password="$1"
  find . -type f -not -path '*/\.git/*' -not -name "$(basename "$0")" -not -name '*.sh' | while IFS= read -r file; do
    echo "Decrypting $file"
    
    # Create a temporary file to store the results
    > "$file.tmp"
    
    while IFS= read -r line; do
      # Decrypt text inside single quotes
      decrypted_line=$(echo "$line" | sed -E "s/'([A-Za-z0-9+/=]+)'/'$(echo -n \1 | openssl enc -aes-256-cbc -d -a -pass pass:$password -pbkdf2)'/")
      
      # Decrypt text inside double quotes
      decrypted_line=$(echo "$decrypted_line" | sed -E 's/"([A-Za-z0-9+/=]+)"/"$(echo -n \1 | openssl enc -aes-256-cbc -d -a -pass pass:$password -pbkdf2)"/')
      
      # Write the decrypted line to the temporary file
      echo "$decrypted_line" >> "$file.tmp"
    done < "$file"
    
    # Replace the original file with the decrypted content
    mv "$file.tmp" "$file"
  done
}


# Parse command-line arguments
commit_message="Encrypted strings in files"
decrypt_only=false
no_git=false
while getopts "m:dng" opt; do
  case $opt in
    m) commit_message="$OPTARG" ;;
    d) decrypt_only=true ;;
    n) no_git=true ;;
    *) echo "Usage: $0 [-m commit_message] [-d] [-ng]"; exit 1 ;;
  esac
done

# Prompt for the password without echoing it
echo "Enter the password for encryption/decryption:"
read -s password

# If no_git is false, check if the current directory is a Git repository
if ! $no_git; then
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "No git repository found. Initializing..."
    git init
  fi
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

  if ! $no_git; then
    # Add changes to git
    git add . &>/dev/null

    # Commit changes with the provided or default message
    git commit -m "$commit_message"

    # Push changes to the remote repository
    echo "Pushing changes to the remote repository"
    git push &>/dev/null
  fi
fi

echo "Operation completed."
