# Function to prompt the user for input
get_user_input() {
  read -p "$1: " input
  echo "$input"
}

keystore_path=$(get_user_input "Enter the keystore path (e.g., /path/to/keystore.keystore)")
keystore_alias=$(get_user_input "Enter the keystore alias")
keystore_password=$(get_user_input "Enter the keystore password")
key_password=$(get_user_input "Enter the key password")

keytool -list -v \
    -alias "$keystore_alias" \
    -keystore "$keystore_path" \
    -keypass "$key_password" \
    -storepass "$keystore_password"