#!/bin/bash
#@@skip

echo "Script started"

# Function to encrypt files
encrypt_files() {
  local password=$1
  for file in *; do
    if [[ -f $file ]] && ! grep -q "#@@skip" "$file" && [[ $file != .* ]]; then
      echo "Encrypting $file"
      tmp_file=$(mktemp)
      openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "$tmp_file" -k "$password"
      mv "$tmp_file" "$file"
    else
      echo "Skipping $file"
    fi
  done
}

# Function to decrypt files
decrypt_files() {
  local password=$1
  for file in *; do
    if [[ -f $file ]] && ! grep -q "#@@skip" "$file" && [[ $file != .* ]]; then
      echo "Decrypting $file"
      tmp_file=$(mktemp)
      openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$file" -out "$tmp_file" -k "$password"
      mv "$tmp_file" "$file"
    else
      echo "Skipping $file"
    fi
  done
}

# Parse command-line arguments
commit_message="Encrypted strings in files"
decrypt_only=false
no_git=false
while getopts "m:dn" opt; do
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
  decrypt_files "$password"
else
  encrypt_files "$password"

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
