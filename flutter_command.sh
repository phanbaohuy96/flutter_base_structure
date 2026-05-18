#!/bin/bash
. ./parse_yaml.sh
. ./echo_color.sh

FLUTTER_VERSION=""
USING_FVM=0

setup_flutter_command() {
  echoColor $GREEN "===> Settup flutter command..."
  local CACHED_DATA_FILE=".fvm_cache"
  if [ -f "$CACHED_DATA_FILE" ]; then
    source "$CACHED_DATA_FILE"
    echoColor $GREEN "===> Using FVM with Flutter version $FLUTTER_VERSION..."
    USING_FVM=1
  else
    USING_FVM=0
  fi
}

run_flutter_command() {
  if [ $USING_FVM == 1  ]; then
    fvm spawn "$FLUTTER_VERSION" "$@"
  else
    flutter "$@"
  fi
}