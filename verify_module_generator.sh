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
# Repositories are retrofit clients, so they can only be generated into a
# package that depends on retrofit. `apps/main` does not (it carries
# retrofit_generator as a dev dependency only), which is exactly the case the
# generator refuses — so the repository half of the gate runs in the data-layer
# package instead, where a real one would go.
DATA_DIR="modules/data_source"
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
# The generator also writes the DI provider for each retrofit client into the
# data-layer module by hand, so that file is restored too.
REGENERATED_FILES="$APP_DIR/build.yaml \
$APP_DIR/lib/di/di.config.dart \
$APP_DIR/lib/presentation/route/route_providers.config.dart \
$DATA_DIR/lib/src/di/data_source_micro.dart \
$DATA_DIR/lib/src/di/data_source_micro.module.dart"

# Everything the generator runs create. The detail generator appends
# `_detail` unless the name already carries it, which `${SMOKE_PREFIX}_detail`
# does.
SMOKE_PATHS="$APP_DIR/lib/presentation/modules/${SMOKE_PREFIX}_common \
$APP_DIR/lib/presentation/modules/${SMOKE_PREFIX}_listing \
$APP_DIR/lib/presentation/modules/${SMOKE_PREFIX}_detail \
$APP_DIR/lib/domain/usecases/${SMOKE_PREFIX}_common \
$APP_DIR/lib/domain/usecases/${SMOKE_PREFIX}_listing \
$APP_DIR/lib/domain/usecases/${SMOKE_PREFIX}_detail \
$APP_DIR/lib/domain/entities/zz_smoke_entity \
$DATA_DIR/lib/src/data/data_source/repository/${SMOKE_PREFIX}_rest \
$DATA_DIR/lib/src/data/data_source/repository/${SMOKE_PREFIX}_graphql \
$DATA_DIR/lib/src/data/models/${SMOKE_PREFIX}_rest.dart \
$DATA_DIR/lib/src/data/models/${SMOKE_PREFIX}_graphql.dart"

# build_runner output that lands beside the scaffolded models. Kept out of
# SMOKE_PATHS because that list is also the format-check list, and generated
# sources are not ours to hold to the formatter.
SMOKE_CODEGEN="$DATA_DIR/lib/src/data/models/${SMOKE_PREFIX}_rest.freezed.dart \
$DATA_DIR/lib/src/data/models/${SMOKE_PREFIX}_rest.g.dart \
$DATA_DIR/lib/src/data/models/${SMOKE_PREFIX}_graphql.freezed.dart \
$DATA_DIR/lib/src/data/models/${SMOKE_PREFIX}_graphql.g.dart"

cleanup() {
  status=$?
  echoColor $GREEN "===> Cleaning up smoke artifacts..."
  rm -rf $SMOKE_PATHS $SMOKE_CODEGEN
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

for path in $SMOKE_PATHS $SMOKE_CODEGEN; do
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

# The repository generator takes a transport instead of an entity, and both
# transports have to survive build_runner: each emits a `@RestApi()` client
# whose implementation only exists after retrofit_generator runs, and the
# GraphQL one emits an extra document library the client imports, so a broken
# emission shows up as a missing part or an unresolved import.
#
# `--model freezed` is spelled out rather than left to the default: the payload
# model is the reason the client has a return type at all, and a gate that
# depends on a default silently stops testing it the day the default moves.
# The class name derives from the repository name (`zz_smoke_rest` ->
# `ZzSmokeRestModel` in `zz_smoke_rest.dart`).
generate_repository() {
  echoColor $GREEN "===> Generating $1 repository '$2'..."
  (
    cd "$DATA_DIR"
    $DART_CMD run module_generator \
      --type repository \
      --name "$2" \
      --transport "$1" \
      --model freezed \
      --non-interactive \
      --force
  )
}

generate common "${SMOKE_PREFIX}_common"
generate listing "${SMOKE_PREFIX}_listing"
generate detail "${SMOKE_PREFIX}_detail"
generate_repository rest "${SMOKE_PREFIX}_rest"
generate_repository graphql "${SMOKE_PREFIX}_graphql"

# build_runner writes these `build_to: source` outputs only when its cached
# result changes. A previous smoke run leaves that cache holding the smoke
# registry while cleanup restores the file from git, so the next run would skip
# the write and the registration check below would read a stale file. Deleting
# the declared outputs first makes build_runner rewrite them unconditionally.
rm -f "$APP_DIR/lib/di/di.config.dart" \
  "$APP_DIR/lib/presentation/route/route_providers.config.dart" \
  "$DATA_DIR/lib/src/di/data_source_micro.module.dart"

echoColor $GREEN "===> Running code generation..."
# data_source first: apps/main's injectable config reads the micro-package
# module this run regenerates, and building the app against a deleted one
# fails with an unhelpful `FormatException: Not an instance of Type`.
(
  cd "$DATA_DIR"
  $DART_CMD run build_runner build --delete-conflicting-outputs
)
(
  cd "$APP_DIR"
  $DART_CMD run module_generator:generate_build_runner_config
  $DART_CMD run build_runner build --delete-conflicting-outputs
)

echoColor $GREEN "===> Analyzing $APP_DIR and $DATA_DIR..."
$FLUTTER_CMD analyze "$APP_DIR" "$DATA_DIR"

echoColor $GREEN "===> Checking formatting of generated files..."
# The DI module is hand-written and edited in place by the generator, so it is
# checked alongside the emitted files: an insertion that is not format-clean
# would fail `make format_check` for the operator, not for us.
$DART_CMD format --output=none --set-exit-if-changed $SMOKE_PATHS \
  "$DATA_DIR/lib/src/di/data_source_micro.dart"

echoColor $GREEN "===> Verifying the generated repositories were bound..."
# A retrofit client cannot carry @Injectable — its implementation is private —
# so the generator writes a @module provider for it. Checking the generated
# registry proves both halves: the provider was inserted, and injectable read
# it.
DATA_REGISTRY="$DATA_DIR/lib/src/di/data_source_micro.module.dart"
for symbol in ZzSmokeRestRepository ZzSmokeGraphqlGraphqlApi ZzSmokeGraphqlRepository; do
  if ! grep -q "$symbol" "$DATA_REGISTRY"; then
    echoColor $RED "===> $symbol is missing from the data_source DI registry"
    exit 1
  fi
done

# A client typed against `Map<String, dynamic>` left the operator to create the
# model in a second run and wire the import by hand, so the generator now
# scaffolds it in the same run. Checking build_runner's output proves the whole
# chain rather than the template alone: freezed accepted the model, and — for
# REST — retrofit knew how to deserialise `ApiResponse<Model>` from it.
echoColor $GREEN "===> Verifying the payload models were generated and used..."
MODEL_DIR="$DATA_DIR/lib/src/data/models"
REPO_DIR="$DATA_DIR/lib/src/data/data_source/repository"

if [ ! -f "$MODEL_DIR/${SMOKE_PREFIX}_rest.freezed.dart" ] ||
  [ ! -f "$MODEL_DIR/${SMOKE_PREFIX}_graphql.freezed.dart" ]; then
  echoColor $RED "===> freezed produced no output for the scaffolded models"
  exit 1
fi

# REST puts the model in the annotated signature, so it reaches retrofit's own
# generated implementation.
REST_CLIENT="$REPO_DIR/${SMOKE_PREFIX}_rest/${SMOKE_PREFIX}_rest_repository.g.dart"
if ! grep -q "ZzSmokeRestModel" "$REST_CLIENT"; then
  echoColor $RED "===> $REST_CLIENT does not deserialise ZzSmokeRestModel"
  exit 1
fi

# GraphQL answers with untyped maps, so the decode is hand-written above the
# client rather than generated into the part.
GRAPHQL_REPO="$REPO_DIR/${SMOKE_PREFIX}_graphql/${SMOKE_PREFIX}_graphql_repository.dart"
if ! grep -q "ZzSmokeGraphqlModel.fromJson" "$GRAPHQL_REPO"; then
  echoColor $RED "===> $GRAPHQL_REPO does not decode ZzSmokeGraphqlModel"
  exit 1
fi

echoColor $GREEN "===> Verifying the generated routes were registered..."
ROUTE_REGISTRY="$APP_DIR/lib/presentation/route/route_providers.config.dart"
for name in "${SMOKE_PREFIX}_common" "${SMOKE_PREFIX}_listing" "${SMOKE_PREFIX}_detail"; do
  if ! grep -q "$name" "$ROUTE_REGISTRY"; then
    echoColor $RED "===> $name is missing from the generated route registry"
    exit 1
  fi
done
