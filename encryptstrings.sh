

echo "Script started"

# Function to encrypt text between quotes in files using Base64 encoding


  find . -type f -not -path '*/\.git/*' | while IFS= read -r file; do
    echo "Encrypting $file"
    while IFS= read -r line; do

      encrypted=$(echo "$line" | sed -E "s/(['\"])([^'\"U2FsdGVkX1+5OSp08qZwYi73J4hOaBZXMIcFo7X9bzc=1$(echo -n \2 | openssl enc -aes-256-cbc -a -salt -pass pass:$password)\3/g")










    echo "Decrypting $file"
    while IFS= read -r line; do








commit_message="Encrypted strings in files"

no_git=false
while getopts "m:dng" opt; do
  case $opt in
    m) commit_message="$OPTARG" ;;
    d) decrypt_only=true ;;
    n) no_git=true ;;




# Prompt for the password without echoing it
echo "Enter the password for encryption/decryption:"
read -s password


if ! $no_git; then

    echo "No git repository found. Initializing..."
    git init

fi


if $decrypt_only; then

  # Decrypt strings recursively in the directory
  decrypt_strings "$password"
else


  encrypt_strings "$password"



    git add . &>/dev/null

    # Commit changes with the provided or default message
    git commit -m "$commit_message"


    echo "Pushing changes to the remote repository"
    git push &>/dev/null



echo "Operation completed."

