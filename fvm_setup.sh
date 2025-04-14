#!/bin/bash

. ./parse_yaml.sh

# Parse YAML to get Flutter version
eval $(parse_yaml fvm_pubspec.yaml)
flutter_version=$fvm_specified_flutter_version

cache_config() {
    local CACHED_DATA_FILE=".fvm_cache"
    # clear all cache
    truncate -s 0 $CACHED_DATA_FILE

    # Save variables to the text file
    echo "USING_FVM=1" >>"$CACHED_DATA_FILE"
    echo "FLUTTER_VERSION=$flutter_version" >>"$CACHED_DATA_FILE"

    if ! grep -q "$CACHED_DATA_FILE" .gitignore; then
        echo "\n$CACHED_DATA_FILE" >>.gitignore
        echo "Added $CACHED_DATA_FILE to .gitignore"

        # Remove the file from Git's tracking
        git rm --cached "$CACHED_DATA_FILE"
    fi
}

cache_config

# Run fvm use in root
fvm use $flutter_version

# Ensure .fvm is in .gitignore
if ! grep -q ".fvm" .gitignore; then
    echo "\n.fvm" >>.gitignore
    echo "Added .fvm to .gitignore"

    # Remove the file from Git's tracking
    git rm --cached ".fvm"
fi

# # Find all subdirectories with pubspec.yaml and run fvm use
# find . -name "pubspec.yaml" -execdir fvm use $flutter_version \;

# # Ensure .fvm is in .gitignore
# if ! grep -q ".fvm" .gitignore; then
#     echo "\n.fvm" >>.gitignore
#     echo "Added .fvm to .gitignore"

#     # Remove the file from Git's tracking
#     git rm --cached ".fvm"
# fi
