#!/bin/bash
#
# End-to-end smoke gate for the module generator.
#
# The static tests in tools/module_generator/test check the templates in
# isolation; this checks the thing that actually matters: that a module
# generated into apps/main survives build_runner and comes out clean under
# `flutter analyze` and `dart format`. It generates one module of every type,
# runs the generation pipeline, checks the result, then removes everything it
# created and restores the files build_runner rewrites.
#
# Deliberately not part of `make check`: it needs the Flutter toolchain and it
# mutates the working tree. Run it manually, and in CI on changes under tools/.
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

. ./echo_color.sh

APP_DIR="apps/main"
SMOKE_PREFIX="zz_smoke"
SMOKE_ENTITY="ZzSmokeEntity"

DART_CMD="dart"
FLUTTER_CMD="flutter"
if command -v fvm >/dev/null 2>&1; then
  DART_CMD="fvm dart"
  FLUTTER_CMD="fvm flutter"
fi

# build_runner rewrites these in place; cleanup restores them from git, so
# refuse to start if they already carry uncommitted work.
REGENERATED_FILES="$APP_DIR/build.yaml \
$APP_DIR/lib/di/di.config.dart \
$APP_DIR/lib/presentation/route/route_providers.config.dart"

# Everything the three generator runs create. The detail generator appends
# `_detail` unless the name already carries it, which `${SMOKE_PREFIX}_detail`
# does.
SMOKE_PATHS="$APP_DIR/lib/presentation/modules/${SMOKE_PREFIX}_common \
$APP_DIR/lib/presentation/modules/${SMOKE_PREFIX}_listing \
$APP_DIR/lib/presentation/modules/${SMOKE_PREFIX}_detail \
$APP_DIR/lib/domain/usecases/${SMOKE_PREFIX}_common \
$APP_DIR/lib/domain/usecases/${SMOKE_PREFIX}_listing \
$APP_DIR/lib/domain/usecases/${SMOKE_PREFIX}_detail \
$APP_DIR/lib/domain/entities/zz_smoke_entity"

cleanup() {
  status=$?
  echoColor $GREEN "===> Cleaning up smoke artifacts..."
  rm -rf $SMOKE_PATHS
  git checkout -- $REGENERATED_FILES 2>/dev/null || true
  if [ $status -eq 0 ]; then
    echoColor $GREEN "===> module generator smoke test PASSED"
  else
    echoColor $RED "===> module generator smoke test FAILED (exit $status)"
  fi
  exit $status
}

for file in $REGENERATED_FILES; do
  if ! git diff --quiet -- "$file" || ! git diff --cached --quiet -- "$file"; then
    echoColor $RED "===> Refusing to run: $file has uncommitted changes."
    echoColor $RED "     This script regenerates and then restores it from git."
    exit 1
  fi
done

for path in $SMOKE_PATHS; do
  if [ -e "$path" ]; then
    echoColor $RED "===> Refusing to run: leftover smoke artifact at $path"
    exit 1
  fi
done

trap cleanup EXIT

generate() {
  echoColor $GREEN "===> Generating $1 module '$2'..."
  (
    cd "$APP_DIR"
    $DART_CMD run module_generator \
      --type "$1" \
      --name "$2" \
      --entity "$SMOKE_ENTITY" \
      --non-interactive \
      --force
  )
}

generate common "${SMOKE_PREFIX}_common"
generate listing "${SMOKE_PREFIX}_listing"
generate detail "${SMOKE_PREFIX}_detail"

# build_runner writes these `build_to: source` outputs only when its cached
# result changes. A previous smoke run leaves that cache holding the smoke
# registry while cleanup restores the file from git, so the next run would skip
# the write and the registration check below would read a stale file. Deleting
# the declared outputs first makes build_runner rewrite them unconditionally.
rm -f "$APP_DIR/lib/di/di.config.dart" \
  "$APP_DIR/lib/presentation/route/route_providers.config.dart"

echoColor $GREEN "===> Running code generation..."
(
  cd "$APP_DIR"
  $DART_CMD run module_generator:generate_build_runner_config
  $DART_CMD run build_runner build --delete-conflicting-outputs
)

echoColor $GREEN "===> Analyzing $APP_DIR..."
$FLUTTER_CMD analyze "$APP_DIR"

echoColor $GREEN "===> Checking formatting of generated files..."
$DART_CMD format --output=none --set-exit-if-changed $SMOKE_PATHS

echoColor $GREEN "===> Verifying the generated routes were registered..."
ROUTE_REGISTRY="$APP_DIR/lib/presentation/route/route_providers.config.dart"
for name in "${SMOKE_PREFIX}_common" "${SMOKE_PREFIX}_listing" "${SMOKE_PREFIX}_detail"; do
  if ! grep -q "$name" "$ROUTE_REGISTRY"; then
    echoColor $RED "===> $name is missing from the generated route registry"
    exit 1
  fi
done
