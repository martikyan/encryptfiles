#!/bin/bash

echo "Script started"

# Function to encrypt all lines in files, grouping 5 lines at a time
encrypt_strings() {
  local password="$1"
  find . -type f -not -path '*/\.git*' -not -name "$(basename "$0")" -not -name '*.sh' | while IFS= read -r file; do
    echo "Encrypting $file"
    
    # Create a temporary file to store the results
    > "$file.tmp"
    
    buffer=""
    line_count=0

    while IFS= read -r line; do
      buffer+="$line"$'\n'
      ((line_count++))

      if (( line_count == 5 )); then
        encrypted_text=$(echo -n "$buffer" | openssl enc -aes-256-cbc -a -salt -pass pass:$password -pbkdf2 | tr -d '\n')
        echo "$encrypted_text" >> "$file.tmp"
        buffer=""
        line_count=0
      fi
    done < "$file"

    # Encrypt any remaining lines in the buffer
    if [ -n "$buffer" ]; then
      encrypted_text=$(echo -n "$buffer" | openssl enc -aes-256-cbc -a -salt -pass pass:$password -pbkdf2 | tr -d '\n')
      echo "$encrypted_text" >> "$file.tmp"
    fi
    
    # Replace the original file with the encrypted content
    mv "$file.tmp" "$file"
  done
}

# Function to decrypt all lines in files, grouping 5 lines at a time
decrypt_strings() {
  local password="$1"
  find . -type f -not -path '*/\.git*' -not -name "$(basename "$0")" -not -name '*.sh' | while IFS= read -r file; do
    echo "Decrypting $file"
    
    # Create a temporary file to store the results
    > "$file.tmp"
    
    while IFS= read -r line; do
      decrypted_text=$(echo -n "$line" | openssl enc -aes-256-cbc -d -a -pass pass:$password -pbkdf2)
      echo "$decrypted_text" >> "$file.tmp"
    done < "$file"
    
    # Replace the original file with the decrypted content
    mv "$file.tmp" "$file"
  done
}

# Parse command-line arguments
commit_message="Encrypted strings in files"
decrypt_only=false
no_git=false
while getopts "m:d:n" opt; do
  case $opt in
    m) commit_message="$OPTARG" ;;
    d) decrypt_only=true ;;
    n) no_git=true ;;
    *) echo "Usage: $0 [-m commit_message] [-d] [-n]"; exit 1 ;;
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
