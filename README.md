# README

## Overview

This script encrypts or decrypts all files in the specified or current directory using AES-256 encryption, with optional Git integration for automatic commits and pushes. Files that contain `#@@skip` are not processed.

## Usage

- **Encrypt Files (default in current directory):**
  ```bash
  encryptfiles
  ```

- **Encrypt Files in a specific directory:**
  ```bash
  encryptfiles -f /path/to/directory
  ```

- **Decrypt Files (default in current directory):**
  ```bash
  encryptfiles -d
  ```

- **Decrypt Files in a specific directory:**
  ```bash
  encryptfiles -d -f /path/to/directory
  ```

### Options

- `-m "message"`: Set a custom Git commit message.
- `-d`: Decrypt files instead of encrypting.
- `-n`: Skip Git operations.
- `-f "directory"`: Specify a directory to encrypt/decrypt files. If not provided, the current working directory is used.

### Example

To encrypt files in `/home/user/documents` and skip Git operations:
```bash
encryptfiles -f /home/user/documents -n
```

To decrypt files in the current directory and push the changes to the remote Git repository:
```bash
encryptfiles -d
```

## Setup

Run the setup script to make the command globally accessible:

```bash
./setup.sh
```

## Requirements

- **OpenSSL**
- **Git** (if using Git features)

## Notes

- Files containing `#@@skip` are not processed.
- Hidden files (`.` prefix) are skipped.
- Ensure the script is executable:
  ```bash
  chmod +x encryptfiles.sh
  ```

---

Now you can use `encryptfiles` from any directory for quick file encryption and decryption, with the flexibility of specifying a target directory and controlling Git operations.

---

## Todo List

- Protect against pushes of unencrypted files.