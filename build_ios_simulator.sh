#!/bin/bash
set -e  # Exit immediately if any command exits with a non-zero status

. ./parse_yaml.sh
. ./echo_color.sh
. ./flutter_command.sh

usage() {
    if [ "$*" != "" ]; then
        echoColor $RED "Error: $*"
    fi
    echoColor $YELLOW '
BUILD iOS SIMULATOR (.app)

USAGE: sh build_ios_simulator.sh [options]
The module must contain dist_config.sh file.

OPTIONS:

-e,     --env                   Environment [dev, staging, sandbox, prod] *
-a,     --app                   Valid values are [<app-name>, all] *
--clean                         Using this option to cleaning the project
-h,     --help                  Display this usage message and exit
--dart-define-from-file         Override dart define from file config
'
    exit 1
}

# Default NEED_TO_CLEAN = false
NEED_TO_CLEAN=false

# Build args
dart_define_from_file=""

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -e | --env)
        ENV="$2"
        shift # past argument
        shift # past value
        ;;
    -a | --app)
        APP="$2"
        shift # past argument
        shift # past value
        ;;
    --clean)
        NEED_TO_CLEAN=true
        shift
        ;;
    -h | --help)
        usage
        shift
        ;;
    --dart-define-from-file)
        dart_define_from_file="$2"
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
if [ -z "$ENV" ] || [ -z "$APP" ]; then
    usage
    exit 1
fi

# Check that ENV is valid
if [ "$ENV" != "dev" ] && [ "$ENV" != "staging" ] && [ "$ENV" != "sandbox" ] && [ "$ENV" != "prod" ]; then
    echoColor $RED "Invalid ENV: $ENV. Valid values are [dev, staging, sandbox, prod]."
    exit 1
fi

# Check that APP is valid
if [ ! -d "./apps/$APP" ] && [ "$APP" != "all" ]; then
    echoColor $RED "Invalid APP: $APP. Valid values are [<app-name>, all]"
    exit 1
fi

echoColor $LIGHT_CYAN "====== BUILD iOS SIMULATOR WITH ARGUMENTS ======"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "||     ENV: $ENV"
echoColor $LIGHT_CYAN "||     APP: $APP"
echoColor $LIGHT_CYAN "||     CLEAN: $NEED_TO_CLEAN"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "================================================="

declare -a build_summary

add_build_status() {
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
        build_summary+=("✅|$action|$app|$time")
    else
        build_summary+=("❌|$action|$app|$time")
    fi
}

clean_folder() {
    local start_time=$(date +%s.%N)

    rm -rf ./ios/Flutter/Generated.xcconfig
    rm -rf ./android/local.properties

    run_flutter_command clean
    run_flutter_command pub get

    local result=$?
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)

    add_build_status -s $result -a "clean_folder" -t $duration

    return $result
}

build_ios_simulator() {
    # Import config file
    . ./dist_config.sh

    # Import project pubspec.yaml as config to get version
    eval $(parse_yaml pubspec.yaml)

    local MAIN=""
    local VERSION=""
    local DART_DEFINE_FROM_FILE=""
    local flavor=$ENV

    case $ENV in
        "dev")
            MAIN=$DEV_MAIN
            VERSION=$version
            if [ -z "$dart_define_from_file" ]; then
                DART_DEFINE_FROM_FILE=$DEV_DART_DEFINE_FROM_FILE
            else
                DART_DEFINE_FROM_FILE=$dart_define_from_file
            fi
            ;;
        "staging")
            MAIN=$STAGING_MAIN
            VERSION=$version_staging
            if [ -z "$dart_define_from_file" ]; then
                DART_DEFINE_FROM_FILE=$STAGING_DART_DEFINE_FROM_FILE
            else
                DART_DEFINE_FROM_FILE=$dart_define_from_file
            fi
            ;;
        "sandbox")
            MAIN=$SANDBOX_MAIN
            VERSION=$version_prod
            if [ -z "$dart_define_from_file" ]; then
                DART_DEFINE_FROM_FILE=$SANDBOX_DART_DEFINE_FROM_FILE
            else
                DART_DEFINE_FROM_FILE=$dart_define_from_file
            fi
            ;;
        "prod")
            MAIN=$PROD_MAIN
            VERSION=$version_prod
            if [ -z "$dart_define_from_file" ]; then
                DART_DEFINE_FROM_FILE=$PROD_DART_DEFINE_FROM_FILE
            else
                DART_DEFINE_FROM_FILE=$dart_define_from_file
            fi
            ;;
        *)
            echoColor $RED "UNKNOWN flavor: $ENV"
            return 1
            ;;
    esac

    # Parse version
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

    echoColor $GREEN "
===> Building iOS Simulator (.app)
    on:             apps/$(basename "$PWD")
    flavor:         $flavor
    main:           $MAIN
    version:        $VERSION
    config_map:     $DART_DEFINE_FROM_FILE
"

    local start_time=$(date +%s.%N)

    run_flutter_command build ios \
     --simulator \
     --flavor $flavor \
     --target=$MAIN \
     --build-name=$BUILD_NAME \
     --build-number=$BUILD_NUMBER \
     --dart-define-from-file=$DART_DEFINE_FROM_FILE

    local result=$?
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)

    add_build_status -s $result -a "build_ios_simulator $flavor" -t $duration

    if [ $result -eq 0 ]; then
        local BUILD_DIR="build/ios/iphonesimulator"
        local APP_PATH="$(find $BUILD_DIR -maxdepth 1 -name "*.app" -type d | head -n 1)"

        if [ -n "$APP_PATH" ]; then
            local APP_NAME="$(basename "$APP_PATH" .app)"
            local ZIP_NAME="${APP_NAME}-${flavor}-${BUILD_NAME}-${BUILD_NUMBER}.app.zip"
            local ZIP_DIR="build/ios/simulator_zip"

            mkdir -p "$ZIP_DIR"

            echoColor $LIGHT_CYAN "===> Zipping $APP_PATH -> $ZIP_DIR/$ZIP_NAME"

            cd "$BUILD_DIR"
            zip -r -y "../simulator_zip/$ZIP_NAME" "$(basename "$APP_PATH")"
            cd - > /dev/null

            echoColor $GREEN "
    .app output: apps/$(basename "$PWD")/$APP_PATH
    .zip output: apps/$(basename "$PWD")/$ZIP_DIR/$ZIP_NAME
"
        else
            echoColor $YELLOW "    WARNING: No .app found in $BUILD_DIR"
        fi
    fi

    return $result
}

ROOT_DIR=$(pwd)

setup_flutter_command

if [[ "all" == $APP ]]; then
    find ./apps -type f -name "dist_config.sh" -not -path '*/\.*' | while read line; do
        BASEDIR=$(dirname "$line")
        echoColor $YELLOW "\n===> Build iOS Simulator $ENV on [$BASEDIR]..."

        cd "$BASEDIR"

        if [ $NEED_TO_CLEAN == true ]; then
            clean_folder
        fi

        build_ios_simulator

        cd "$ROOT_DIR"
    done
else
    if [ -f "./apps/$APP/dist_config.sh" ] && [ -d "./apps/$APP" ]; then
        cd apps/$APP

        if [ $NEED_TO_CLEAN == true ]; then
            clean_folder
        fi

        build_ios_simulator
    fi
fi

echo ""
echoColor $LIGHT_CYAN "============== BUILD DONE =============="
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "||     ENV: $ENV"
echoColor $LIGHT_CYAN "||     APP: $APP"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "========================================"

echoColor $YELLOW "
----------------- BUILD SUMMARY -----------------
|"

for element in "${build_summary[@]}"; do
    while IFS="|" read -ra elements; do
        echo "|    ${elements[0]}  Action: ${elements[1]}
|        App:   ${elements[2]}
|        Time:   ${elements[3]}(s)
|"
    done <<<"$element"
done

echoColor $YELLOW "------------------------------------------------"
