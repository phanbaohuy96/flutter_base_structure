#!/bin/bash
. ./parse_yaml.sh
. ./echo_color.sh
. ./flutter_command.sh

# Function to prompt the user for input
get_user_input() {
    read -p "$1: " input
    echo "$input"
}

usage() {
    if [ "$*" != "" ]; then
        echoColor $RED "Error: $*"
    fi
    echoColor $YELLOW '
DISTRIBUTION SCRIPT

USAGE: sh distribution.sh [options]
The module must be contain dist_config.sh file.
Example for dist_config.sh file:
-----------------------------------------------------------------
# Dev
dev_main="lib/main_dev.dart" #required
dev_development_exportOptionsPlist="none" #optional
dev_appstore_exportOptionsPlist="none" #optional

# Staging
staging_main="lib/main_staging.dart" #required
staging_development_exportOptionsPlist="none" #optional
staging_appstore_exportOptionsPlist="none" #optional

# Prod
prod_main="lib/main.dart" #required
prod_development_exportOptionsPlist="none" #optional
prod_appstore_exportOptionsPlist="none" #optional
-----------------------------------------------------------------

NOTE: The optional value must not be empty if not provided. Input any place holder value.

OPTIONS:

-e,     --env       Environment [dev, staging, prod] *
-p,     --platform  Valid values are [android, ios, all] *
-a,     --app       Valid values are [<app-name>, all] *
-t,     --target    Default using firebase target to distribute. Valid values are [firebase, appstore, all]
--clean             Using this option to cleaning the project
-h,     --help      Display this usage message and exit
-g,     --group     Valid values are [internal, external, all, custom]. Default value is all.
'
    exit 1
}

# Set default values of arguments to "internal"
GROUP=internal
INPUT_TESTER_GROUP=""
TESTER_LIST=""
# Specify the path for the output file
CACHED_DATA_FILE=".dist_cache"

# Set default values of arguments to "firebase"
TARGET=firebase

# Default NEED_TO_CLEAN = false
NEED_TO_CLEAN=false

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -e | --env)
        ENV="$2"
        shift # past argument
        shift # past value
        ;;
    -p | --platform)
        PLATFORM="$2"
        shift # past argument
        shift # past value
        ;;
    -a | --app)
        APP="$2"
        shift # past argument
        shift # past value
        ;;
    -t | --target)
        TARGET="$2"
        shift # past argument
        shift # past value
        ;;
    --clean)
        NEED_TO_CLEAN=true
        shift
        ;;
    -h | --help)
        echoColor $RED "$1"
        usage
        shift
        ;;
    -g | --group)
        GROUP="$2"
        shift # past argument
        shift # past value
        ;;
    *)
        usage
        shift
        ;;
    esac
done

# Check that required arguments were provided
if [ -z "$ENV" ] || [ -z "$PLATFORM" ] || [ -z "$APP" ]; then
    usage
    exit 1
fi

# Check that ENV is valid
if [ "$ENV" != "dev" ] && [ "$ENV" != "staging" ] && [ "$ENV" != "prod" ]; then
    echoColor $RED "Invalid ENV: $ENV. Valid values are dev, [dev, staging, prod]."
    exit 1
fi

# Check that PLATFORM is valid
if [ "$PLATFORM" != "android" ] && [ "$PLATFORM" != "ios" ] && [ "$PLATFORM" != "all" ]; then
    echoColor $RED "Invalid PLATFORM: $PLATFORM. Valid values are [android, ios, all]."
    exit 1
fi

# Check that APP is valid
if [ ! -d "./apps/$APP" ] && [ "$APP" != "all" ]; then
    echoColor $RED "Invalid APP: $APP. Valid values are [<app-name>, all]"
    exit 1
fi

# Check that TARGET is valid
if [ "$TARGET" != "appstore" ] && [ "$TARGET" != "firebase" ] && [ "$TARGET" != "all" ]; then
    echoColor $RED "Invalid TARGET: $TARGET. Valid values are [appstore, firebase, all]."
    exit 1
fi

cache_password() {
    # clear all cache
    truncate -s 0 $CACHED_DATA_FILE

    # Save variables to the text file
    echo "APPSTORE_USERNAME=$APPSTORE_USERNAME" >>"$CACHED_DATA_FILE"
    echo "APPSTORE_PASSWORD=$APPSTORE_PASSWORD" >>"$CACHED_DATA_FILE"

    echo "Distribution data saved to $CACHED_DATA_FILE"

    if ! grep -q "$CACHED_DATA_FILE" .gitignore; then
        echo "\n$CACHED_DATA_FILE" >>.gitignore
        echo "Added $CACHED_DATA_FILE to .gitignore"

        # Remove the file from Git's tracking
        git rm --cached "$CACHED_DATA_FILE"

    fi

}

load_cached_password() {
    source "$CACHED_DATA_FILE"
}

if [ "$TARGET" == "appstore" ] || [ "$TARGET" == "all" ]; then
    if [ -f "$CACHED_DATA_FILE" ]; then
        load_cached_password

        break
    fi

    while [ -z "$APPSTORE_USERNAME" ] || [ -z "$APPSTORE_PASSWORD" ]; do
        APPSTORE_USERNAME=$(get_user_input "Enter the appstore username")
        APPSTORE_PASSWORD=$(get_user_input "Enter the appstore specific password")
    done

    cache_password

fi

if [[ "$GROUP" != *"internal"* ]] && [[ "$GROUP" != *"external"* ]] && [[ "$GROUP" != *"all"* ]] && [[ "$GROUP" != *"custom"* ]]; then
    echoColor $RED "Invalid GROUP: $GROUP. Valid values are [internal, external, all, custom]."
    exit 1
fi

if [[ "$GROUP" == *"custom"* ]]; then
    INPUT_TESTER_GROUP="$(get_user_input "Enter the distribution tester group"),"
    TESTER_LIST="$(get_user_input "Enter the distribution tester list"),"
fi

echoColor $LIGHT_CYAN "====== RUNNING DISTRIBUTION WITH ARGUMENTS ======"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "||     ENV: $ENV"
echoColor $LIGHT_CYAN "||     PLATFORM: $PLATFORM"
echoColor $LIGHT_CYAN "||     APP: $APP"
echoColor $LIGHT_CYAN "||     TARGET: $TARGET"
echoColor $LIGHT_CYAN "||     CLEAN: $NEED_TO_CLEAN"
echoColor $LIGHT_CYAN "||     GROUP OPTION: $GROUP"
echoColor $LIGHT_CYAN "||     GROUP: $FINAL_TESTER_GROUP"
echoColor $LIGHT_CYAN "||     TESTERS: $TESTER_LIST"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "================================================="

declare -a distribution_summary

add_dist_status() {
    local status=-1
    local action=""
    local time=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -s | --status)
            status=$2
            shift # past argument
            shift # past value
            ;;
        -a | --action)
            action="$2"
            shift # past argument
            shift # past value
            ;;
        -t | --time)
            time="$2"
            shift # past argument
            shift # past value
            ;;
        esac
    done

    local app="$(basename "$PWD")"

    if [ $status == 0 ]; then
        distribution_summary+=("✅|$action|$app|$time")
    else
        distribution_summary+=("❌|$action|$app|$time")
    fi
}

clean_folder() {
    # Capture the start time
    local start_time=$(date +%s.%N)

    rm -rf ./ios/Flutter/Generated.xcconfig

    rm -rf ./android/local.properties

    run_flutter_command clean
    run_flutter_command pub get

    local result=$?

    # Capture the end time
    local end_time=$(date +%s.%N)

    # Calculate the duration in seconds
    local duration=$(echo "$end_time - $start_time" | bc)

    add_dist_status -s $result -a "clean_folder" -t $duration

    return $result
}

upload_appstore() {
    # Capture the start time
    local start_time=$(date +%s.%N)

    echoColor $LIGHT_CYAN "
===> Uploading to APPSTORE
    on:             apps/$(basename "$PWD")
"
    xcrun altool --upload-app --type ios --file build/ios/ipa/*.ipa --username $APPSTORE_USERNAME --password $APPSTORE_PASSWORD

    local result=$?
    # Capture the end time
    local end_time=$(date +%s.%N)

    # Calculate the duration in seconds
    local duration=$(echo "$end_time - $start_time" | bc)

    add_dist_status -s $result -a "upload_appstore" -t $duration

    return $result
}

upload_firebase() {
    local flavor=""
    local platform=""
    local ios_internal_tester_group=""
    local ios_external_tester_group=""
    local android_internal_tester_group=""
    local android_external_tester_group=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -f | --flavor)
            flavor="$2"
            shift # past argument
            shift # past value
            ;;
        -p | --platform)
            platform="$2"
            shift # past argument
            shift # past value
            ;;
        -iitg | --ios_internal_tester_group)
            ios_internal_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        -ietg | --ios_external_tester_group)
            ios_external_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        -aitg | --android_internal_tester_group)
            android_internal_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        -aetg | --android_external_tester_group)
            android_external_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        esac
    done

    # Capture the start time
    local start_time=$(date +%s.%N)

    local BINARY_PATH=""
    if [ $platform == "ios" ]; then
        local BUILD_DIR="build/ios/ipa"
        BINARY_PATH="$(find $BUILD_DIR -type f -name "*.ipa" | head -n 1)"

    elif [ $platform == "android" ]; then
        local BUILD_DIR="build/app/outputs/flutter-apk"

        BINARY_PATH="$(find $BUILD_DIR -type f -name '*.apk' | head -n 1)"
    fi

    local TEMP=""
    local FINAL_TESTER_GROUP=$INPUT_TESTER_GROUP

    if [[ "$GROUP" == *"internal"* ]]; then
        if [ "$platform" == "ios" ]; then
            TEMP="${ios_internal_tester_group}"
        else
            TEMP="${android_internal_tester_group}"
        fi
    elif [[ "$GROUP" == *"external"* ]]; then
        if [ "$platform" == "ios" ]; then
            TEMP="${ios_external_tester_group}"
        else
            TEMP="${android_external_tester_group}"
        fi
    elif [[ "$GROUP" == *"all"* ]]; then
        if [ "$platform" == "ios" ]; then
            TEMP="${ios_internal_tester_group},${ios_external_tester_group}"
        else
            TEMP="${android_internal_tester_group},${android_external_tester_group}"
        fi
    fi

    FINAL_TESTER_GROUP="${FINAL_TESTER_GROUP}${TEMP}"

    if [[ $FINAL_TESTER_GROUP == *"," ]]; then
        FINAL_TESTER_GROUP="${FINAL_TESTER_GROUP%?}"
    fi

    if [[ $TESTER_LIST == *"," ]]; then
        TESTER_LIST="${TESTER_LIST%?}"
    fi

    echoColor $LIGHT_CYAN "
===> Uploading to Firebase
    on:             apps/$(basename "$PWD")
    flavor:         $flavor
    platform:       $platform
    binary:         "apps/$(basename "$PWD")/$BINARY_PATH"
    group option:   "$GROUP"
    tester groups:  "$FINAL_TESTER_GROUP"
    tester lists:   "$TESTER_LIST"
"

    bundle exec fastlane $platform "upload_firebase_$flavor" binary_path:"$BINARY_PATH" group:"$FINAL_TESTER_GROUP" testers:"$TESTER_LIST"

    local result=$?

    # Capture the end time
    local end_time=$(date +%s.%N)

    # Calculate the duration in seconds
    local duration=$(echo "$end_time - $start_time" | bc)

    add_dist_status -s $result -a "upload_firebase_$flavor $platform" -t $duration

    return $result
}

build_android() {
    local flavor=""
    local main=""
    local VERSION=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -f | --flavor)
            flavor="$2"
            shift # past argument
            shift # past value
            ;;
        -m | --main)
            main="$2"
            shift # past argument
            shift # past value
            ;;
        -v | --version)
            VERSION="$2"
            shift # past argument
            shift # past value
            ;;
        esac
    done

    echoColor $LIGHT_CYAN "
===> Building Android
    on:          apps/$(basename "$PWD")
    flavor:      $flavor
    main:        $main
    version:     $VERSION
"

    # Capture the start time
    local start_time=$(date +%s.%N)

    # Regular expression to match the version format x.y.z+w
    VERSION_PARTEN='^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'
    local BUILD_NAME=""
    local BUILD_NUMBER=""

    if [[ $VERSION =~ $VERSION_PARTEN ]]; then
        read -r x y z w <<<$(echo "$VERSION" | awk -F '[.+]' '{print $1,$2,$3,$4}')

        BUILD_NAME="$x.$y.$z"
        BUILD_NUMBER=$w
    else
        echoColor $YELLOW "
    WARNING: The version string '$VERSION' does not match the format x.y.z+w.
"
    fi

    rm -rf build/app/outputs/flutter-apk

    run_flutter_command build apk --flavor $flavor --release --target=$main --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER

    local result=$?

    # Capture the end time
    local end_time=$(date +%s.%N)

    # Calculate the duration in seconds
    local duration=$(echo "$end_time - $start_time" | bc)

    add_dist_status -s $result -a "build_android $flavor" -t $duration

    return $result
}

build_ios() {
    local flavor=""
    local main=""
    local export_options=""
    local VERSION=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -f | --flavor)
            flavor="$2"
            shift # past argument
            shift # past value
            ;;
        -m | --main)
            main="$2"
            shift # past argument
            shift # past value
            ;;
        -e | --export-options)
            export_options="$2"
            shift # past argument
            shift # past value
            ;;
        -v | --version)
            VERSION="$2"
            shift # past argument
            shift # past value
            ;;
        esac
    done

    echoColor $GREEN "
===> Building iOS
    on:             apps/$(basename "$PWD")
    flavor:         $flavor
    main:           $main
    export_options: $export_options
    version:        $VERSION
"

    # Capture the start time
    local start_time=$(date +%s.%N)

    # Regular expression to match the version format x.y.z+w
    VERSION_PARTEN='^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'
    local BUILD_NAME=""
    local BUILD_NUMBER=""

    if [[ $VERSION =~ $VERSION_PARTEN ]]; then
        read -r x y z w <<<$(echo "$VERSION" | awk -F '[.+]' '{print $1,$2,$3,$4}')

        BUILD_NAME="$x.$y.$z"
        BUILD_NUMBER=$w
    else
        echoColor $YELLOW "
    WARNING: The version string '$VERSION' does not match the format x.y.z+w.
"
    fi

    rm -rf build/ios/ipa

    if [ "$export_options" == "" ] || [ ! -f "./$export_options" ]; then
        run_flutter_command build ipa --flavor $flavor --release --target=lib/main.dart --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER
    else
        run_flutter_command build ipa --flavor $flavor --release --target=lib/main.dart --export-options-plist=$export_options --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER
    fi

    local result=$?

    # Capture the end time
    local end_time=$(date +%s.%N)

    # Calculate the duration in seconds
    local duration=$(echo "$end_time - $start_time" | bc)

    add_dist_status -s $result -a "build_ios $flavor" -t $duration

    return $result
}

re_archive_ios() {
    local export_options=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -e | --export-options)
            export_options="$2"
            shift # past argument
            shift # past value
            ;;
        esac
    done

    echoColor $LIGHT_CYAN "===> Signing iOS with
    export_options: $export_options
"

    # Capture the start time
    local start_time=$(date +%s.%N)

    rm -rf build/ios/ipa

    xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive -exportPath build/ios/ipa -exportOptionsPlist $export_options

    local result=$?

    # Capture the end time
    local end_time=$(date +%s.%N)

    # Calculate the duration in seconds
    local duration=$(echo "$end_time - $start_time" | bc)

    add_dist_status -s $result -a "re_archive_ios exportOptionsPlist:$export_options" -t $duration

    return $result
}

deploy() {
    local flavor=""
    local main=""
    local export_options=""
    local appstore_export_options=""
    local VERSION=""
    local ios_internal_tester_group=""
    local ios_external_tester_group=""
    local android_internal_tester_group=""
    local android_external_tester_group=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -f | --flavor)
            flavor="$2"
            shift # past argument
            shift # past value
            ;;
        -m | --main)
            main="$2"
            shift # past argument
            shift # past value
            ;;
        -e | --export-options)
            export_options="$2"
            shift # past argument
            shift # past value
            ;;
        -ae | --appstore-export-options)
            appstore_export_options="$2"
            shift # past argument
            shift # past value
            ;;
        -v | --version)
            VERSION="$2"
            shift # past argument
            shift # past value
            ;;
        -iitg | --ios_internal_tester_group)
            ios_internal_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        -ietg | --ios_external_tester_group)
            ios_external_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        -aitg | --android_internal_tester_group)
            android_internal_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        -aetg | --android_external_tester_group)
            android_external_tester_group="$2"
            shift # past argument
            shift # past value
            ;;
        esac
    done

    if [[ "$PLATFORM" == "all" || "$PLATFORM" == "android" ]] && [ -d "android" ]; then
        if [ "$TARGET" == "firebase" ] || [ "$TARGET" == "all" ]; then
            build_android -v $VERSION -f $flavor -m $main

            if [ $? -eq 0 ]; then
                upload_firebase -f $flavor -p "android" --android_internal_tester_group $android_internal_tester_group --android_external_tester_group $android_external_tester_group
            fi
        fi
    fi
    if [[ "$PLATFORM" == "all" || "$PLATFORM" == "ios" ]] && [ -d "ios" ]; then

        if [ "$TARGET" == "firebase" ]; then
            build_ios -v $VERSION -f $flavor -m $main --export-options $export_options

            if [ $? -eq 0 ]; then
                upload_firebase -f $flavor -p "ios" --ios_internal_tester_group $ios_internal_tester_group --ios_external_tester_group $ios_external_tester_group
            fi

        elif [ "$TARGET" == "appstore" ]; then
            build_ios -v $VERSION -f $flavor -m $main --export-options $appstore_export_options

            if [ $? -eq 0 ]; then
                upload_appstore
            fi

        elif [ "$TARGET" == "all" ]; then
            build_ios -v $VERSION -f $flavor -m $main

            if [ $? -eq 0 ]; then
                re_archive_ios --export-options $export_options

                if [ $? -eq 0 ]; then
                    upload_firebase -f $flavor -p "ios"
                fi

                re_archive_ios --export-options $appstore_export_options

                if [ $? -eq 0 ]; then
                    upload_appstore
                fi
            fi
        fi
    fi
}

distribution() {
    # Import config file
    . ./dist_config.sh

    # Import project pubspec.yaml as config to get version
    eval $(parse_yaml pubspec.yaml)

    if [[ "dev" == *"$ENV"* ]]; then
        deploy --flavor $ENV --main $dev_main --export-options $dev_development_exportOptionsPlist --appstore-export-options $dev_appstore_exportOptionsPlist --version $version --ios_internal_tester_group $dev_ios_internal_tester_group --ios_external_tester_group $dev_ios_external_tester_group --android_internal_tester_group $dev_android_internal_tester_group --android_external_tester_group $dev_android_external_tester_group
    fi

    if [[ "staging" == *"$ENV"* ]]; then
        deploy --flavor $ENV --main $staging_main --export-options $staging_development_exportOptionsPlist --appstore-export-options $staging_appstore_exportOptionsPlist --version $version_staging --ios_internal_tester_group $staging_ios_internal_tester_group --ios_external_tester_group $staging_ios_external_tester_group --android_internal_tester_group $staging_android_internal_tester_group --android_external_tester_group $staging_android_external_tester_group
    fi

    if [[ "prod" == *"$ENV"* ]]; then
        deploy --flavor $ENV --main $prod_main --export-options $prod_development_exportOptionsPlist --appstore-export-options $prod_appstore_exportOptionsPlist --version $version_prod --ios_internal_tester_group $prod_ios_internal_tester_group --ios_external_tester_group $prod_ios_external_tester_group --android_internal_tester_group $prod_android_internal_tester_group --android_external_tester_group $prod_android_external_tester_group
    fi
}

ROOT_DIR=$(pwd)

setup_flutter_command

if [[ "all" == $APP ]]; then
    find ./apps -type f -name "dist_config.sh" -not -path '*/\.*' | while read line; do
        BASEDIR=$(dirname "$line")
        echoColor $YELLOW "\n===> Distribute $ENV on [$BASEDIR]..."

        cd "$BASEDIR"

        if [ $NEED_TO_CLEAN == true ]; then
            clean_folder
        fi

        distribution

        cd "$ROOT_DIR"
    done
else
    if [ -f "./apps/$APP/dist_config.sh" ] && [ -d "./apps/$APP" ]; then
        cd apps/$APP

        if [ $NEED_TO_CLEAN == true ]; then
            clean_folder
        fi

        distribution
    fi
fi

echo ""
echoColor $LIGHT_CYAN "============== DONE DISTRIBUTION =============="
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "||     ENV: $ENV"
echoColor $LIGHT_CYAN "||     PLATFORM: $PLATFORM"
echoColor $LIGHT_CYAN "||     APP: $APP"
echoColor $LIGHT_CYAN "||     TARGET: $TARGET"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "==============================================="

echoColor $YELLOW "
----------------- DISTRIBUTION SUMMARY -----------------
|"

for element in "${distribution_summary[@]}"; do
    while IFS="|" read -ra elements; do
        echo "|    ${elements[0]}  Action: ${elements[1]}
|        App:   ${elements[2]}
|        Time:   ${elements[3]}(s)
|"
    done <<<"$element"
done

echoColor $YELLOW "--------------------------------------------------------"
