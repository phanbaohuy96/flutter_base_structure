#!/bin/bash

# Function to prompt the user for input
get_user_input() {
  read -p "$1: " input
  echo "$input"
}

# Get the keystore parameters from the user
keystore_path=$(get_user_input "Enter the keystore path (e.g., /path/to/keystore.keystore)")
keystore_alias=$(get_user_input "Enter the keystore alias")
keystore_password=$(get_user_input "Enter the keystore password")
key_password=$(get_user_input "Enter the key password")
keystore_validity_days=$(get_user_input "Enter the keystore validity in days (e.g., 365)")

# Generate the keystore using keytool
keytool -genkeypair -v \
  -keystore "$keystore_path" \
  -alias "$keystore_alias" \
  -keyalg RSA \
  -keysize 2048 \
  -validity "$keystore_validity_days" \
  -keypass "$key_password" \
  -storepass "$keystore_password"

echo "Android keystore created successfully at: $keystore_path"
