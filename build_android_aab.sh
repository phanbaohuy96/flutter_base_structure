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
    if [ "$*" != "" ] ; then
        echoColor $RED "Error: $*"
    fi
    echoColor $YELLOW '
USAGE: sh build_android_aab.sh [options]
The module must be contain dist_config.sh file.
Example for dist_config.sh file:
-----------------------------------------------------------------
# Dev
dev_main="lib/main_dev.dart" #required

# Demo Version
demo_main="lib/main_demo.dart" #required

# Staging
staging_main="lib/main_staging.dart" #required

# Prod
prod_main="lib/main.dart" #required
-----------------------------------------------------------------

NOTE: The optional value must not be empty if not provided. Input any place holder value.

OPTIONS:

-e,     --env       Environment [dev, demo, staging, prod] *
-a,     --app       Valid values are [<app-name>, all] *
--clean             Using this option to cleaning the project
-h,     --help      Display this usage message and exit
'
    exit 1
}

# Set default values of arguments to "firebase"
TARGET=firebase

# Default NEED_TO_CLEAN = false
NEED_TO_CLEAN=false

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--env)
    ENV="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--platform)
    PLATFORM="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--app)
    APP="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--target)
    TARGET="$2"
    shift # past argument
    shift # past value
    ;;
    --clean)
    NEED_TO_CLEAN=true
    shift
    ;;
    -h|--help)
    echoColor $RED "$1"
    usage
    shift
    ;;
    *)
    usage
    shift
esac
done

# Check that required arguments were provided
if [ -z "$ENV" ] || [ -z "$APP" ]; then
    usage
    exit 1
fi

# Check that ENV is valid
if [ "$ENV" != "dev" ] && [ "$ENV" != "demo" ]&& [ "$ENV" != "staging" ] && [ "$ENV" != "prod" ]; then
    echoColor $RED "Invalid ENV: $ENV. Valid values are dev, [dev, demo, staging, prod]."
    exit 1
fi

# Check that APP is valid
if [ ! -d "./apps/$APP" ] && [ "$APP" != "all" ]; then
    echoColor $RED "Invalid APP: $APP. Valid values are [<app-name>, all]"
    exit 1
fi

clean_folder () {
    # Capture the start time
    local start_time=$(date +%s.%N)

    rm -rf ./ios/Flutter/Generated.xcconfig

    rm -rf ./android/local.properties

    run_flutter_command clean; run_flutter_command pub get

    local result=$?

    # Capture the end time
    local end_time=$(date +%s.%N)

    # Calculate the duration in seconds
    local duration=$(echo "$end_time - $start_time" | bc)

    return $result
}

function build_aab {

    local flavor=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--flavor)
                flavor="$2"
                shift # past argument
                shift # past value
                ;;
        esac
    done

    local VERSION=""
    case $flavor in
        "dev")
            VERSION=$version
            MAIN=$dev_main
            ;;

        "demo")
            VERSION=$version_demo
            MAIN=$demo_main
            ;;

        "staging")
            VERSION=$version_staging
            MAIN=$staging_main
            ;;

        "prod")
            VERSION=$version_prod
            MAIN=$prod_main
            ;;
        *)
            echo -n "UNKNOW Flavor"
            ;;
    esac

    # Regular expression to match the version format x.y.z+w
    VERSION_PARTEN='^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$'
    local BUILD_NAME=""
    local BUILD_NUMBER=""

    if [[ $VERSION =~ $VERSION_PARTEN ]]; then
        read -r x y z w <<< $(echo "$VERSION" | awk -F '[.+]' '{print $1,$2,$3,$4}')

        BUILD_NAME="$x.$y.$z"
        BUILD_NUMBER=$w
    else
        echoColor $YELLOW "
    WARNING: The version string '$VERSION' does not match the format x.y.z+w.
"
    fi

    echoColor $LIGHT_CYAN "
===> Building AAB
    on:          apps/$(basename "$PWD")
    flavor:      $flavor
    main:        $MAIN
    version:     $VERSION
"

    run_flutter_command build appbundle\
     --flavor $flavor\
     --release\
     --target=$MAIN\
     --build-name=$BUILD_NAME\
     --build-number=$BUILD_NUMBER
}

setup_flutter_command

ROOT_DIR=$(pwd)

if [[ "all" == $APP ]];then
    find ./apps -type f -name "dist_config.sh" -not -path '*/\.*' | while read line; do
        BASEDIR=$(dirname "$line")
        echoColor $YELLOW "\n===> Build On $ENV on [$BASEDIR]..."

        cd "$BASEDIR"

        # Import config file
        . ./dist_config.sh

        # Import project pubspec.yaml as config to get version
        eval $(parse_yaml pubspec.yaml)

        if [ $NEED_TO_CLEAN == true ]; then
            clean_folder
        fi

        build_aab -f $ENV

        cd "$ROOT_DIR"
    done
else
    if [ -f "./apps/$APP/dist_config.sh" ] && [ -d "./apps/$APP" ];then
        cd apps/$APP

        # Import config file
        . ./dist_config.sh

        # Import project pubspec.yaml as config to get version
        eval $(parse_yaml pubspec.yaml)

        if [ $NEED_TO_CLEAN == true ]; then
            clean_folder
        fi

        build_aab -f $ENV
    fi
fi