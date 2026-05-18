#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DART_CMD="dart"
if command -v fvm >/dev/null 2>&1; then
  DART_CMD="fvm dart"
fi

cd "$ROOT_DIR/tools/module_generator"

$DART_CMD run module_generator:create_project --template-root "$ROOT_DIR" "$@"
