#!/bin/bash
#@@skip

echo "Script started"

protect_git() {
  echo "Protecting .git directory"
  mv .git .git.bak &>/dev/null || echo ".git directory not found"
}

unprotect_git() {
  echo "Restoring .git directory"
  mv .git.bak .git &>/dev/null || echo ".git.bak directory not found"
}

get_file_password() {
  if [[ -f .password ]]; then
    password=$(cat .password)
    echo $password
  fi
}

double_hash() {
  # double hash the password with a salt 'salt'
  password_hash=$(echo -n "salt$1" | sha256sum | awk '{print $1}' | sha256sum | awk '{print $1}')
  echo $password_hash
}

# Function to encrypt files
encrypt_files() {
  local password=$1
  for file in *; do
    if [[ -f $file ]]; then
      if grep -q "#@@skip" "$file"; then
        echo "Skipping $file (reason: #@@skip tag found)"
      elif [[ $(basename "$file") == .* && $(basename "$file") != "." && $(basename "$file") != ".." ]]; then
        echo "Skipping $file (reason: hidden file)"
      elif [[ $file == *.enc ]]; then
        echo "Skipping $file (reason: already encrypted)"
      else
        echo "Encrypting $file"
        tmp_file=$(mktemp)
        openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "$tmp_file" -k "$password"
        if [[ $? -ne 0 ]]; then
          echo "Error occurred during encryption. Aborting."
          exit 1
        fi
        mv "$tmp_file" "$file.enc"
        rm "$file"
      fi
    else
      echo "Skipping $file (reason: not a regular file)"
    fi
  done
}

# Function to decrypt files
decrypt_files() {
  local password=$1
  for file in *.enc; do
    if [[ -f $file ]]; then
      if grep -q "#@@skip" "$file"; then
        echo "Skipping $file (reason: #@@skip tag found)"
      elif [[ $(basename "$file") == .* && $(basename "$file") != "." && $(basename "$file") != ".." ]]; then
        echo "Skipping $file (reason: hidden file)"
      elif [[ $file != *.enc ]]; then
        echo "Skipping $file (reason: not an encrypted file)"
      else
        echo "Decrypting $file"
        tmp_file=$(mktemp)
        openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$file" -out "$tmp_file" -k "$password"
        if [[ $? -ne 0 ]]; then
          echo "Error occurred during decryption. Aborting."
          exit 1
        fi
        mv "$tmp_file" "${file%.enc}"
        rm $file
      fi
    else
      echo "Skipping $file (reason: not a regular file)"
    fi
  done
}

# Parse command-line arguments
commit_message="Encrypt files automatically"
decrypt_only=false
no_git=false
directory="."

# Check if the first argument is a directory
if [ -d "$1" ]; then
  directory="$1"
  shift
fi

echo "Parsing command-line arguments"
while getopts "m:dnf:" opt; do
  case $opt in
    m) commit_message="$OPTARG" ;;
    d) decrypt_only=true ;;
    n) no_git=true ;;
    f) directory="$OPTARG" ;;
    *) echo "Usage: $0 [directory] [-m commit_message] [-d] [-n] [-f directory]"; exit 1 ;;
  esac
done

# Save the original directory
original_dir=$(pwd)

# Change to the target directory
cd "$directory" || { echo "Failed to change to directory $directory. Exiting."; exit 1; }

# get_input_password get_file_password double_hash

password=$(get_file_password)
if [[ -z "$password" ]]; then
  # if file password is empty, get input password
  if $decrypt_only; then
    echo "Enter the password for decryption:"
  else
    echo "Enter the password for encryption:"
  fi
  read -s password
  
  # Only ask for password confirmation if encrypting files
  if ! $decrypt_only; then
    echo "Re-enter the password for confirmation:"
    read -s password_confirm
    if [[ "$password" != "$password_confirm" ]]; then
      echo "Passwords do not match. Exiting."
      exit 1
    fi
  fi
  # double hash the password
  password_hash=$(double_hash $password)
  echo $password_hash > .password
  password=$password_hash
fi

# If no_git is false, check if the current directory is a Git repository
if ! $no_git; then
  if [[ ! -d .git && ! -d .git.bak ]]; then
    echo "No git repository found in $directory. Skipping git operations."
    no_git=true
  fi
fi

echo "Processing files in $directory"
if $decrypt_only; then
  protect_git
  decrypt_files "$password"
else
  encrypt_files "$password"
  unprotect_git
  if ! $no_git; then
    # Add changes to git
    git add ':/*.enc' &>/dev/null

    # Commit changes with the provided or default message
    git commit -m "$commit_message"

    # Push changes to the remote repository
    echo "Pushing changes to the remote repository"
    git push
  fi
fi

# Return to the original directory
cd "$original_dir" || { echo "Failed to return to the original directory. Exiting."; exit 1; }

echo "Operation completed."
