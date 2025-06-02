#!/bin/bash

. ./parse_yaml.sh
. ./echo_color.sh
. ./flutter_command.sh

usage() {
    if [ "$*" != "" ] ; then
        echoColor $RED "Error: $*"
    fi
    echoColor $YELLOW '
SCRIPT CLEAN PROJECT

USAGE: sh clean.sh [options]
OPTIONS:
-h,     --help       display this usage message and exit

-f,    --force       force clean all folder in project (i.e: sh clean -f or sh clean --force)
'

    exit 1
}

# count item
index=0
isForce=0

while [ $# -gt 0 ] ; do
    case "$1" in
        -f|--force)
            isForce=1
            shift
            ;;
        -h|--help)
            usage
            shift
            ;;
        *)
            usage
            shift
    esac
    shift
done

echoColor $GREEN "------------ START CLEAN PROJECT ------------ \n"
ROOT_DIR=$(pwd)

echoColor $GREEN "------------ Force clean project ------------"
total=$(find . -type f -name "pubspec.yaml" -not -path '*/\.*' | wc -l)
total="${total// /}"
echoColor $LIGHT_CYAN "----------------------------------------------------------"
echoColor $LIGHT_CYAN "$total Folders have been scanned. Start cleaning..."
echoColor $LIGHT_CYAN "----------------------------------------------------------"

setup_flutter_command

# go to all the directory are contains file pubspec.yaml to call clean and pub get
find . -type f -name "pubspec.yaml" -not -path '*/\.*' | while read line; do
    index=$(( index + 1 ))
    BASEDIR=$(dirname "$line")
    echoColor $YELLOW "===> Clean [$BASEDIR]..."

    cd "$BASEDIR"
    
    run_flutter_command clean

    if [ $isForce == 1 ]; then
      rm -rf pubspec.lock
    fi

    run_flutter_command pub get

    if [ -d "./ios" ]; then
      echoColor $YELLOW "===> Pod install [$BASEDIR/ios]..."

      cd ios

      if [ $isForce == 1 ]; then
        pod deintegrate; rm -rf podfile.lock; pod update
      fi
      if [[ $(uname -p) == 'arm' ]]; then
        arch -x86_64 pod install
      fi
      if [[ $(uname -p) != 'arm' ]]; then
        pod install
      fi
      cd ..
    fi
    
    cd "$ROOT_DIR"

    echoColor $GREEN "---------- Done [$index/$total] ----------\n"
done

echoColor $GREEN "------------ CLEAN PROJECT DONE ------------ \n"