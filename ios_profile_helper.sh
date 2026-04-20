#!/bin/bash

# Script to prepare provisioning profiles and certificates for CI/CD
# This script helps encode files to base64 for storing as GitHub Secrets

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APPS_DIR="$SCRIPT_DIR/apps"

echo "=================================================="
echo "iOS CI/CD Provisioning Profile Encoder"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROFILES_DIR="$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"

# Global variables for selected app
SELECTED_APP=""
SELECTED_APP_PATH=""
declare -a APP_ENVS
declare -a APP_BUNDLE_IDS

echo -e "${BLUE}This script will help you encode provisioning profiles and certificates${NC}"
echo -e "${BLUE}for storing as GitHub Secrets or other CI/CD secrets management.${NC}"
echo ""

# Function to parse YAML (simple key-value extraction for our use case)
parse_yaml() {
    local yaml_file="$1"
    
    if [ ! -f "$yaml_file" ]; then
        return 1
    fi
    
    # Read iOS bundle IDs from app_identifier.yaml
    local in_ios_section=0
    local current_env=""
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Check if we're in the iOS section
        if [[ "$line" =~ ^ios: ]]; then
            in_ios_section=1
            continue
        fi
        
        # Exit iOS section if we hit android or another top-level key
        if [[ $in_ios_section -eq 1 && "$line" =~ ^[a-z]+:[[:space:]]*$ ]]; then
            in_ios_section=0
        fi
        
        # Parse environments and packages in iOS section
        if [[ $in_ios_section -eq 1 ]]; then
            # Match environment like "  dev:" or "  staging:"
            if [[ "$line" =~ ^[[:space:]]+([a-z_]+):[[:space:]]*$ ]]; then
                current_env="${BASH_REMATCH[1]}"
            # Match package line like "    package: com.example.app.dev"
            elif [[ "$line" =~ ^[[:space:]]+package:[[:space:]]+(.+)$ && -n "$current_env" ]]; then
                local package="${BASH_REMATCH[1]}"
                APP_ENVS+=("$current_env")
                APP_BUNDLE_IDS+=("$package")
            fi
        fi
    done < "$yaml_file"
    
    return 0
}

# Function to select app
select_app() {
    echo ""
    echo -e "${BLUE}Select an app from the workspace:${NC}"
    echo ""
    
    if [ ! -d "$APPS_DIR" ]; then
        echo -e "${RED}❌ Apps directory not found: $APPS_DIR${NC}"
        exit 1
    fi
    
    local index=1
    declare -a app_dirs
    
    for app_dir in "$APPS_DIR"/*; do
        if [ -d "$app_dir" ]; then
            local app_name=$(basename "$app_dir")
            local app_id_file="$app_dir/app_identifier.yaml"
            
            if [ -f "$app_id_file" ]; then
                app_dirs[$index]="$app_dir"
                echo -e "${YELLOW}$index)${NC} $app_name"
                ((index++))
            fi
        fi
    done
    
    if [ ${#app_dirs[@]} -eq 0 ]; then
        echo -e "${RED}❌ No apps found with app_identifier.yaml!${NC}"
        exit 1
    fi
    
    echo ""
    read -p "Choose an app (1-${#app_dirs[@]}): " app_choice
    
    if [ -z "${app_dirs[$app_choice]}" ]; then
        echo -e "${RED}Invalid selection!${NC}"
        exit 1
    fi
    
    SELECTED_APP=$(basename "${app_dirs[$app_choice]}")
    SELECTED_APP_PATH="${app_dirs[$app_choice]}"
    
    echo -e "${GREEN}✅ Selected app: $SELECTED_APP${NC}"
    echo ""
    
    # Parse app_identifier.yaml
    local app_id_file="$SELECTED_APP_PATH/app_identifier.yaml"
    if ! parse_yaml "$app_id_file"; then
        echo -e "${RED}❌ Failed to parse app_identifier.yaml${NC}"
        exit 1
    fi
    
    if [ ${#APP_BUNDLE_IDS[@]} -eq 0 ]; then
        echo -e "${RED}❌ No iOS bundle IDs found in app_identifier.yaml${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Found ${#APP_BUNDLE_IDS[@]} environment(s):${NC}"
    local i=0
    for env in "${APP_ENVS[@]}"; do
        echo "  - $env: ${APP_BUNDLE_IDS[$i]}"
        ((i++))
    done
    echo ""
}

# Function to encode file
encode_file() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}❌ File not found: $file_path${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}📄 File: $file_name${NC}"
    echo "---"
    
    # Encode to base64
    local encoded=$(base64 -i "$file_path")
    
    # Copy to clipboard
    echo "$encoded" | pbcopy
    
    echo -e "${GREEN}✅ Base64 encoded and copied to clipboard!${NC}"
    echo ""
    echo "Paste this into your GitHub Secret."
    echo ""
    
    # Show first 100 chars as preview
    echo "Preview (first 100 chars):"
    echo "${encoded:0:100}..."
    echo ""
    
    return 0
}

# Function to list provisioning profiles
list_profiles() {
    echo -e "${BLUE}Available Provisioning Profiles:${NC}"
    echo ""
    
    local index=1
    declare -g -a profile_files
    
    if [ ! -d "$PROFILES_DIR" ]; then
        echo -e "${RED}❌ Provisioning profiles directory not found!${NC}"
        return 1
    fi
    
    for profile in "$PROFILES_DIR"/*.mobileprovision; do
        if [ -f "$profile" ]; then
            local profile_name=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Name raw - 2>/dev/null)
            local bundle_id=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Entitlements.application-identifier raw - 2>/dev/null | cut -d. -f2-)
            
            profile_files[$index]="$profile"
            echo -e "${YELLOW}$index)${NC} $profile_name"
            echo "   Bundle ID: $bundle_id"
            echo "   File: $(basename "$profile")"
            echo "   Date: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$profile")"
            echo ""
            
            ((index++))
        fi
    done
    
    if [ ${#profile_files[@]} -eq 0 ]; then
        echo -e "${RED}❌ No provisioning profiles found!${NC}"
        return 1
    fi
    
    return 0
}

# Function to clean up old/duplicate provisioning profiles
clean_old_profiles() {
    echo ""
    echo -e "${BLUE}Checking for duplicate provisioning profiles...${NC}"
    echo ""
    
    if [ ! -d "$PROFILES_DIR" ]; then
        echo -e "${RED}❌ Provisioning profiles directory not found!${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    # Create associative arrays to track profiles by bundle ID
    declare -a bundle_ids
    declare -a profile_names
    declare -a profile_paths
    declare -a profile_dates
    
    # Collect all profiles with their info
    for profile in "$PROFILES_DIR"/*.mobileprovision; do
        if [ -f "$profile" ]; then
            local bundle_id=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Entitlements.application-identifier raw - 2>/dev/null | cut -d. -f2-)
            local profile_name=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Name raw - 2>/dev/null)
            local profile_date=$(stat -f "%m" "$profile")
            
            bundle_ids+=("$bundle_id")
            profile_names+=("$profile_name")
            profile_paths+=("$profile")
            profile_dates+=("$profile_date")
        fi
    done
    
    if [ ${#bundle_ids[@]} -eq 0 ]; then
        echo -e "${YELLOW}No provisioning profiles found.${NC}"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    # Find and remove duplicates (keep the newest)
    local removed_count=0
    local i=0
    
    while [ $i -lt ${#bundle_ids[@]} ]; do
        local current_bundle="${bundle_ids[$i]}"
        local current_name="${profile_names[$i]}"
        local current_path="${profile_paths[$i]}"
        local current_date="${profile_dates[$i]}"
        
        # Find all profiles with the same bundle ID
        local j=$((i + 1))
        while [ $j -lt ${#bundle_ids[@]} ]; do
            if [ "${bundle_ids[$j]}" = "$current_bundle" ]; then
                # Found duplicate bundle ID
                local other_name="${profile_names[$j]}"
                local other_path="${profile_paths[$j]}"
                local other_date="${profile_dates[$j]}"
                
                # Keep the newer one, remove the older one
                if [ "$current_date" -gt "$other_date" ]; then
                    # Current is newer, remove other
                    echo -e "${YELLOW}Found duplicate for bundle ID: $current_bundle${NC}"
                    echo -e "  Keeping: $current_name ($(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$current_path"))"
                    echo -e "  ${RED}Removing: $other_name ($(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$other_path"))${NC}"
                    rm "$other_path"
                    removed_count=$((removed_count + 1))
                    # Remove from arrays
                    unset bundle_ids[$j]
                    unset profile_names[$j]
                    unset profile_paths[$j]
                    unset profile_dates[$j]
                    # Reindex arrays
                    bundle_ids=("${bundle_ids[@]}")
                    profile_names=("${profile_names[@]}")
                    profile_paths=("${profile_paths[@]}")
                    profile_dates=("${profile_dates[@]}")
                else
                    # Other is newer, remove current
                    echo -e "${YELLOW}Found duplicate for bundle ID: $current_bundle${NC}"
                    echo -e "  Keeping: $other_name ($(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$other_path"))"
                    echo -e "  ${RED}Removing: $current_name ($(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$current_path"))${NC}"
                    rm "$current_path"
                    removed_count=$((removed_count + 1))
                    # Remove from arrays
                    unset bundle_ids[$i]
                    unset profile_names[$i]
                    unset profile_paths[$i]
                    unset profile_dates[$i]
                    # Reindex arrays
                    bundle_ids=("${bundle_ids[@]}")
                    profile_names=("${profile_names[@]}")
                    profile_paths=("${profile_paths[@]}")
                    profile_dates=("${profile_dates[@]}")
                    # Don't increment i since we removed current
                    i=$((i - 1))
                    break
                fi
            fi
            j=$((j + 1))
        done
        
        i=$((i + 1))
    done
    
    echo ""
    if [ $removed_count -eq 0 ]; then
        echo -e "${GREEN}✅ No duplicate profiles found. All clean!${NC}"
    else
        echo -e "${GREEN}✅ Removed $removed_count old/duplicate profile(s)${NC}"
    fi
    echo ""
    
    read -p "Press Enter to continue..."
    show_menu
}

# Main menu
show_menu() {
    echo "=================================================="
    echo "What would you like to encode?"
    echo "=================================================="
    echo ""
    echo "1) Provisioning Profile (.mobileprovision)"
    echo "2) Certificate (.p12)"
    echo "3) Certificate (.cer)"
    echo "4) All provisioning profiles for this project"
    echo "5) Clean up old/duplicate provisioning profiles"
    echo "6) Exit"
    echo ""
    read -p "Choose an option (1-6): " choice
    
    case $choice in
        1)
            encode_provisioning_profile
            ;;
        2)
            encode_certificate
            ;;
        3)
            encode_cer_certificate
            ;;
        4)
            encode_all_project_profiles
            ;;
        5)
            clean_old_profiles
            ;;
        6)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            show_menu
            ;;
    esac
}

encode_provisioning_profile() {
    echo ""
    if ! list_profiles; then
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    read -p "Select profile number (or 0 to go back): " selection
    
    if [ "$selection" = "0" ]; then
        show_menu
        return
    fi
    
    if [ -n "${profile_files[$selection]}" ]; then
        encode_file "${profile_files[$selection]}"
        
        # Show suggested secret name
        local profile_name=$(security cms -D -i "${profile_files[$selection]}" 2>/dev/null | plutil -extract Name raw - 2>/dev/null)
        local bundle_id=$(security cms -D -i "${profile_files[$selection]}" 2>/dev/null | plutil -extract Entitlements.application-identifier raw - 2>/dev/null | cut -d. -f2-)
        
        echo -e "${BLUE}💡 Suggested GitHub Secret name:${NC}"
        local env_suffix=""
        for i in "${!APP_BUNDLE_IDS[@]}"; do
            if [[ "$bundle_id" == "${APP_BUNDLE_IDS[$i]}" ]]; then
                env_suffix=$(echo "${APP_ENVS[$i]}" | tr '[:lower:]' '[:upper:]')
                break
            fi
        done
        
        if [ -n "$env_suffix" ]; then
            echo "IOS_${env_suffix}_PROVISIONING_PROFILE"
        else
            echo "IOS_PROVISIONING_PROFILE"
        fi
        echo ""
        
        echo -e "${BLUE}💡 Also create a secret for the profile name:${NC}"
        echo "Secret value: \"$profile_name\""
        echo ""
    else
        echo -e "${RED}Invalid selection!${NC}"
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

encode_certificate() {
    echo ""
    echo "Please provide the path to your .p12 certificate file:"
    echo "(You can drag and drop the file here)"
    echo ""
    read -p "File path: " cert_path
    
    # Remove quotes if present
    cert_path=$(echo "$cert_path" | tr -d '"' | tr -d "'")
    
    if encode_file "$cert_path"; then
        echo -e "${BLUE}💡 Suggested GitHub Secret name:${NC}"
        echo "IOS_DISTRIBUTION_CERTIFICATE"
        echo ""
        echo -e "${YELLOW}⚠️  Don't forget to also create a secret for the certificate password:${NC}"
        echo "Secret name: IOS_CERTIFICATE_PASSWORD"
        echo "Secret value: [your certificate password]"
        echo ""
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

encode_cer_certificate() {
    echo ""
    echo "Please provide the path to your .cer certificate file:"
    echo "(You can drag and drop the file here)"
    echo ""
    read -p "File path: " cert_path
    
    # Remove quotes if present
    cert_path=$(echo "$cert_path" | tr -d '"' | tr -d "'")
    
    if encode_file "$cert_path"; then
        echo -e "${BLUE}💡 Suggested GitHub Secret name:${NC}"
        echo "IOS_CERTIFICATE"
        echo ""
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

encode_all_project_profiles() {
    echo ""
    echo -e "${BLUE}Encoding all profiles for app: $SELECTED_APP${NC}"
    echo ""
    
    local output_file="provisioning_profiles_encoded_${SELECTED_APP}.txt"
    echo "# Encoded Provisioning Profiles for CI/CD" > "$output_file"
    echo "# App: $SELECTED_APP" >> "$output_file"
    echo "# Generated on $(date)" >> "$output_file"
    echo "" >> "$output_file"
    
    local i=0
    for env in "${APP_ENVS[@]}"; do
        local bundle_id="${APP_BUNDLE_IDS[$i]}"
        i=$((i + 1))
        
        local found_profile=0
        for profile in "$PROFILES_DIR"/*.mobileprovision; do
            if [ -f "$profile" ]; then
                local profile_bundle=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Entitlements.application-identifier raw - 2>/dev/null | cut -d. -f2-)
                
                if [[ "$profile_bundle" == "$bundle_id" ]]; then
                    local profile_name=$(security cms -D -i "$profile" 2>/dev/null | plutil -extract Name raw - 2>/dev/null)
                    local encoded=$(base64 -i "$profile")
                    local env_upper=$(echo "$env" | tr '[:lower:]' '[:upper:]')
                    
                    echo "## ${env_upper} Environment" >> "$output_file"
                    echo "Profile Name: $profile_name" >> "$output_file"
                    echo "Bundle ID: $bundle_id" >> "$output_file"
                    echo "Date added: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$profile")" >> "$output_file"
                    echo "" >> "$output_file"
                    echo "GitHub Secret Name: IOS_${env_upper}_PROVISIONING_PROFILE" >> "$output_file"
                    echo "GitHub Secret Value:" >> "$output_file"
                    echo "$encoded" >> "$output_file"
                    echo "" >> "$output_file"
                    echo "Profile Name Secret: IOS_${env_upper}_PROFILE_NAME" >> "$output_file"
                    echo "Profile Name Value: \"$profile_name\"" >> "$output_file"
                    echo "" >> "$output_file"
                    echo "---" >> "$output_file"
                    echo "" >> "$output_file"
                    
                    echo -e "${GREEN}✅ Encoded $env profile: $profile_name${NC}"
                    found_profile=1
                fi
            fi
        done
        
        if [ $found_profile -eq 0 ]; then
            echo -e "${YELLOW}⚠️  No profile found for $env ($bundle_id)${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ All profiles encoded!${NC}"
    echo -e "${BLUE}Saved to: $output_file${NC}"
    echo ""
    echo "You can now copy the values from this file to your GitHub Secrets."
    echo ""
    
    read -p "Open the file now? (y/n): " open_file
    if [[ "$open_file" =~ ^[Yy]$ ]]; then
        open "$output_file"
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

# Start the script
select_app
echo -e "${GREEN}Ready to encode your iOS code signing files for CI/CD!${NC}"
echo ""
show_menu
