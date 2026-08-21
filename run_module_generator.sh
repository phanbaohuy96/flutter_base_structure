#!/bin/bash
#
# Launches the module generator.
#
# Usage: sh run_module_generator.sh [package-dir] [generator flags...]
#   sh run_module_generator.sh                      # pick the package from a menu
#   sh run_module_generator.sh modules/data_source  # skip the menu
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# The package is chosen inside the generator now: it scans the workspace and
# offers a menu that also says which packages can host a retrofit client. This
# script only needs a package to launch from — any one that depends on
# module_generator will do, and the generator moves itself from there.
TARGET_DIR="$ROOT_DIR/apps/main"
# A leading non-flag argument names the package, which then skips the menu.
if [ $# -ge 1 ] && [ "${1#-}" = "$1" ]; then
  if [ ! -d "$ROOT_DIR/$1" ]; then
    echo "No such package directory: $1"
    exit 66
  fi
  PACKAGE="$1"
  TARGET_DIR="$ROOT_DIR/$1"
  shift
  set -- --package "$PACKAGE" "$@"
fi

# Mirror the makefile's FVM-aware DART wrapper.
DART_CMD="dart"
if command -v fvm >/dev/null 2>&1; then
  DART_CMD="fvm dart"
fi

echo "================== Module Generator In $TARGET_DIR =================="

# Run in a subshell so the caller's working directory is untouched. The old
# `cd $1; ...; cd ../` landed in `apps/`, not the repo root.
(
  cd "$TARGET_DIR"
  $DART_CMD run module_generator "$@"
)
