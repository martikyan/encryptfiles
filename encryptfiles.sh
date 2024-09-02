#!/bin/bash
#@@skip

echo "Script started"

# Function to encrypt files
encrypt_files() {
  local password=$1
  local dir=${2:-.}  # Default to current directory if no directory is provided
  echo "Encrypting files in directory: $dir"
  for file in "$dir"/*; do
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
  local dir=${2:-.}  # Default to current directory if no directory is provided
  echo "Decrypting files in directory: $dir"
  for file in "$dir"/*; do
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
dir_to_process="."
while getopts "m:dnd:" opt; do
  case $opt in
    m) commit_message="$OPTARG" ;;
    d) decrypt_only=true ;;
    n) no_git=true ;;
    d) dir_to_process="$OPTARG" ;;
    *) echo "Usage: $0 [-m commit_message] [-d] [-n] [-d directory]"; exit 1 ;;
  esac
done

# Print the directory to be processed
echo "Directory to be processed: $dir_to_process"

# Prompt for the password without echoing it
if $decrypt_only; then
  echo "Enter the password for decryption:"
  read -s password
else
  echo "Enter the password for encryption:"
  read -s password
  echo "Confirm the password:"
  read -s password_confirm
  if [ "$password" != "$password_confirm" ]; then
    echo "Passwords do not match. Exiting."
    exit 1
  fi
fi

# If no_git is false, check if the current directory is a Git repository
if ! $no_git && ! $decrypt_only; then
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "No git repository found. Initializing..."
    git init
  fi
fi

echo "Processing files"
if $decrypt_only; then
  decrypt_files "$password" "$dir_to_process"
else
  encrypt_files "$password" "$dir_to_process"

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
