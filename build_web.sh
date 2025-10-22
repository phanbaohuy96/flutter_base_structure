#!/bin/bash
set -e  # Exit immediately if any command exits with a non-zero status

. ./parse_yaml.sh
. ./echo_color.sh

# Function to prompt the user for input
get_user_input() {
    read -p "$1: " input
    echo "$input"
}

usage() {
    if [ "$*" != "" ]; then
        echoColor $RED "Error: $*"
    fi
    echoColor $YELLOW 'OPTIONS:
-e,     --env               Environment [dev, staging, sandbox, prod] *
-a,     --app               Valid values are [<app-name>, all] *
-h,     --help              Display this usage message and exit
--dart-define-from-file     Override dart define from file config
'
    exit 1
}

# Error handler function
error_handler() {
    local exit_code=$?
    local line_number=$1
    echoColor $RED "❌ Script failed at line $line_number with exit code $exit_code"
    exit $exit_code
}

# Set up error trap
trap 'error_handler $LINENO' ERR

# Build args
MAIN=""
VERSION=""
BASE_HREF="/"
DART_DEFINE_FROM_FILE=""
APP_DOMAIN=""

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
    -h | --help)
        echoColor $RED "$1"
        usage
        shift
        ;;
    --dart-define-from-file)
        DART_DEFINE_FROM_FILE="$2"
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
    echoColor $RED "Invalid ENV: $ENV. Valid values are dev, [dev, staging, sandbox, prod]."
    exit 1
fi

# Check that APP is valid
if [ ! -d "./apps/$APP" ] && [ "$APP" != "all" ]; then
    echoColor $RED "Invalid APP: $APP. Valid values are [<app-name>, all]"
    exit 1
fi

echoColor $LIGHT_CYAN "====== RUNNING BUILD WEB WITH ARGUMENTS ======"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "||     ENV: $ENV"
echoColor $LIGHT_CYAN "||     APP: $APP"
echoColor $LIGHT_CYAN "||     CLEAN: $NEED_TO_CLEAN"
echoColor $LIGHT_CYAN "||"
echoColor $LIGHT_CYAN "=============================================="

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

distribution() {
    # Import config file
    . ./dist_config.sh

    # Import project pubspec.yaml as config to get version
    eval $(parse_yaml pubspec.yaml)
    eval $(grep -v '^#' .env | xargs)

    APP_DOMAIN=$WEB_APP_DOMAIN
    BASE_HREF=$WEB_BASE_HREF

    if [[ "dev" == *"$ENV"* ]]; then
        MAIN=$DEV_MAIN
        VERSION=$version
        if [$dart_define_from_file == ""]; then
            DART_DEFINE_FROM_FILE=$DEV_DART_DEFINE_FROM_FILE
        fi
    fi

    if [[ "staging" == *"$ENV"* ]]; then
        MAIN=$STAGING_MAIN
        VERSION=$version_staging
        if [$dart_define_from_file == ""]; then
            DART_DEFINE_FROM_FILE=$STAGING_DART_DEFINE_FROM_FILE
        fi
    fi

    if [[ "sandbox" == *"$ENV"* ]]; then
        MAIN=$SANDBOX_MAIN
        VERSION=$version_prod
        if [$dart_define_from_file == ""]; then
            DART_DEFINE_FROM_FILE=$SANDBOX_DART_DEFINE_FROM_FILE
        fi
    fi

    if [[ "prod" == *"$ENV"* ]]; then
        MAIN=$PROD_MAIN
        VERSION=$version_prod
        if [$dart_define_from_file == ""]; then
            DART_DEFINE_FROM_FILE=$PROD_DART_DEFINE_FROM_FILE
        fi
    fi

    echoColor $GREEN "
===> Building Web
    on:             apps/$(basename "$PWD")
    main:           $MAIN
    version:        $VERSION
    base-href:      $BASE_HREF
    config_map:     $DART_DEFINE_FROM_FILE
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

    flutter pub get || {
        echoColor $RED "❌ flutter pub get failed"
        exit 1
    }

    flutter build web \
     --base-href=$BASE_HREF \
     --release \
     --target=$MAIN \
     --build-name=$BUILD_NAME \
     --build-number=$BUILD_NUMBER \
     --no-tree-shake-icons \
     --no-source-maps \
     --dart-define-from-file=$DART_DEFINE_FROM_FILE || {
        echoColor $RED "❌ flutter build web failed"
        exit 1
    }

    cd build/web || { 
        echoColor $RED "❌ build/web not found. Flutter build web failed."
        exit 1
    }

    # Determine correct sed -i command based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_CMD="sed -i ''"
    SED_INPLACE=(-i '')
    else
    SED_CMD="sed -i"
    SED_INPLACE=(-i)
    fi

    # Step 1: Rename main.dart.js
    MAIN_HASH=$(sha256sum main.dart.js | cut -d ' ' -f1) || {
        echoColor $RED "❌ Failed to generate hash for main.dart.js"
        exit 1
    }
    NEW_MAIN="main.dart.${MAIN_HASH:0:8}.js"
    echo "🔁 Renaming main.dart.js → $NEW_MAIN"
    eval $SED_CMD "s/main\.dart\.js/${NEW_MAIN}/g" flutter_bootstrap.js || {
        echoColor $RED "❌ Failed to update flutter_bootstrap.js"
        exit 1
    }
    mv main.dart.js "$NEW_MAIN" || {
        echoColor $RED "❌ Failed to rename main.dart.js"
        exit 1
    }

    # Step 2: Rename flutter_bootstrap.js
    BOOTSTRAP_HASH=$(sha256sum flutter_bootstrap.js | cut -d ' ' -f1) || {
        echoColor $RED "❌ Failed to generate hash for flutter_bootstrap.js"
        exit 1
    }
    NEW_BOOTSTRAP="flutter_bootstrap.${BOOTSTRAP_HASH:0:8}.js"
    echo "🔁 Renaming flutter_bootstrap.js → $NEW_BOOTSTRAP"
    eval $SED_CMD "s/flutter_bootstrap\.js/${NEW_BOOTSTRAP}/g" index.html || {
        echoColor $RED "❌ Failed to update index.html"
        exit 1
    }
    mv flutter_bootstrap.js "$NEW_BOOTSTRAP" || {
        echoColor $RED "❌ Failed to rename flutter_bootstrap.js"
        exit 1
    }

    echo "✅ Done. Assets hashed and references updated."

    # Step 3: Update meta Open Graph Image
    sed "${SED_INPLACE[@]}" "s|__APP_DOMAIN__|$APP_DOMAIN|g" index.html || {
        echoColor $RED "❌ Failed to inject APP_DOMAIN into index.html"
        exit 1
    }
    echo "✅ Injected APP_DOMAIN into og:image: $APP_DOMAIN"

    # back to the root of the app
    cd ../..

    local result=$?

    if [[ $result == 0 ]]; then
        echoColor $GREEN "apps/$(basename "$PWD")/build/web"
    fi

    add_dist_status -s $result -a "build_web $flavor" -t "--"

    return $result
}

ROOT_DIR=$(pwd)

if [[ "all" == $APP ]]; then
    find ./apps -type f -name "dist_config.sh" -not -path '*/\.*' | while read line; do
        BASEDIR=$(dirname "$line")
        echoColor $YELLOW "\n===> Distribute $ENV on [$BASEDIR]..."

        cd "$BASEDIR" || {
            echoColor $RED "❌ Failed to change directory to $BASEDIR"
            exit 1
        }

        if [ $NEED_TO_CLEAN == true ]; then
            clean_folder
        fi

        distribution

        cd "$ROOT_DIR" || {
            echoColor $RED "❌ Failed to return to root directory"
            exit 1
        }
    done
else
    if [ -f "./apps/$APP/dist_config.sh" ] && [ -d "./apps/$APP" ]; then
        cd apps/$APP || {
            echoColor $RED "❌ Failed to change directory to apps/$APP"
            exit 1
        }

        if [[ $NEED_TO_CLEAN == true ]]; then
            clean_folder
        fi

        distribution
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

for element in "${distribution_summary[@]}"; do
    while IFS="|" read -ra elements; do
        echo "|    ${elements[0]}  Action: ${elements[1]}
|        App:   ${elements[2]}
|        Time:   ${elements[3]}(s)
|"
    done <<<"$element"
done

echoColor $YELLOW "------------------------------------------------"