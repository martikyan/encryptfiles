





  local password="U2FsdGVkX19gwiVuy2GkFT4JbopNrbXeA1brzzYscm8=1"

    echo "Encrypting $file"
    while IFS= read -r line; do
      echo "Processing line: $line"



    mv "$file.tmp" "$file"



# Function to decrypt text between quotes in files using Base64 encoding



    echo "Decrypting $file"



    done < "$file"


}



decrypt_only=false
no_sync=false


    m) commit_message="$OPTARG" ;;



  esac




read -s password









  echo "Decrypting strings in files"

  decrypt_strings "$password"

  echo "Encrypting strings in files"

  encrypt_strings "$password"


  git add . &>/dev/null




  # Push changes to the remote repository

    echo "Pushing changes to the remote repository"
    git push &>/dev/null



echo "Operation completed."
