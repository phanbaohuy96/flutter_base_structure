#!/bin/bash
#
# Runs the module generator inside a package directory.
#
# Usage: sh run_module_generator.sh apps/main [generator flags...]
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -lt 1 ]; then
  echo "Usage: sh run_module_generator.sh <package-dir>   # eg. apps/main"
  exit 64
fi

TARGET_DIR="$ROOT_DIR/$1"
if [ ! -d "$TARGET_DIR" ]; then
  echo "No such package directory: $1"
  exit 66
fi
shift

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
