# README for `encryptfiles`

## Overview

This script encrypts or decrypts all files in the current directory using AES-256, with optional Git integration for automatic commits and pushes.

## Usage

- **Encrypt Files:**
  ```bash
  encryptfiles
  ```
- **Decrypt Files:**
  ```bash
  encryptfiles -d
  ```

### Options

- `-m "message"`: Set a custom Git commit message.
- `-d`: Decrypt files instead of encrypting.
- `-n`: Skip Git operations.

## Setup

Run the setup script to make the command globally accessible:

```bash
./setup.sh
```

## Requirements

- **OpenSSL**
- **Git** (if using Git features)

## Notes

- Files with `#@@skip` are not processed.
- Ensure the script is executable:
  ```bash
  chmod +x encryptfiles.sh
  ```

---

Now you can use `encryptfiles` from any directory for quick file encryption and decryption.