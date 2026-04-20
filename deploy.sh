#!/usr/bin/env bash
#
# deploy.sh — automate dev/staging deployment
#
# Usage:
#   ./deploy.sh dev        Merge main → develop, bump `version`, push.
#   ./deploy.sh staging    Merge main → release/staging, bump `version_staging`,
#                          push, publish prerelease v{semver}-staging.{build}.
#   ./deploy.sh both       Run dev then staging.
#
# Requirements: git, gh (authenticated), a clean working tree.
#

set -euo pipefail

PUBSPEC="apps/main/pubspec.yaml"
DEV_BRANCH="develop"
STAGING_BRANCH="release/staging"

# --- colors ---
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_BLUE=$'\033[34m'
else
  C_RESET=''; C_BOLD=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_BLUE=''
fi
info()  { printf "%s▶%s %s\n" "$C_BLUE" "$C_RESET" "$*"; }
ok()    { printf "%s✓%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf "%s!%s %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
fail()  { printf "%s✗%s %s\n" "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# --- helpers ---

# Read "X.Y.Z+N" for a given key from pubspec.yaml.
read_version() {
  local key="$1"
  grep -E "^${key}: " "$PUBSPEC" | head -1 | sed -E "s/^${key}: *//"
}

# Bump only the build number (the part after `+`) for a given key.
# Prints the new "X.Y.Z+N" string.
bump_build_number() {
  local key="$1"
  local current semver build new_build new_version
  current="$(read_version "$key")"
  [ -n "$current" ] || fail "Could not read '$key' from $PUBSPEC"
  case "$current" in
    *+*) ;;
    *) fail "'$key: $current' has no build number to bump" ;;
  esac
  semver="${current%+*}"
  build="${current##*+}"
  case "$build" in
    ''|*[!0-9]*) fail "Build number '$build' is not numeric" ;;
  esac
  new_build=$((build + 1))
  new_version="${semver}+${new_build}"
  # macOS-portable in-place edit
  sed -i.bak -E "s/^${key}: .*/${key}: ${new_version}/" "$PUBSPEC"
  rm -f "${PUBSPEC}.bak"
  printf "%s" "$new_version"
}

confirm() {
  local prompt="$1" reply
  printf "%s%s%s [y/N] " "$C_BOLD" "$prompt" "$C_RESET"
  read -r reply
  [ "$reply" = "y" ] || [ "$reply" = "Y" ]
}

# Switch to a branch, hard-aligning to its origin tip. Safe because we've
# already verified the working tree is clean.
checkout_fresh() {
  local branch="$1"
  info "Checking out $branch (hard-aligned to origin/$branch)"
  git checkout -B "$branch" "origin/$branch" >/dev/null
}

merge_main_into_current() {
  local target="$1"
  info "Merging origin/main into $target"
  if ! git merge --no-edit origin/main; then
    warn "Merge conflict — aborting merge. Resolve manually, then re-run."
    git merge --abort || true
    fail "Merge into $target failed."
  fi
}

# --- preflight ---
preflight() {
  [ -f "$PUBSPEC" ] || fail "$PUBSPEC not found. Run from the repo root."
  command -v gh >/dev/null 2>&1 || fail "gh CLI is required (brew install gh)."
  if [ -n "$(git status --porcelain)" ]; then
    fail "Working tree is not clean. Commit or stash changes first."
  fi
  info "Fetching origin"
  git fetch origin --prune
}

# --- deploys ---

deploy_dev() {
  printf "\n%s== DEV deployment ==%s\n" "$C_BOLD" "$C_RESET"
  checkout_fresh "$DEV_BRANCH"
  merge_main_into_current "$DEV_BRANCH"

  local new_version
  new_version="$(bump_build_number version)"
  ok "Bumped version → $new_version"

  git add "$PUBSPEC"
  git commit -m "chore(release): bump dev version to $new_version" >/dev/null
  ok "Committed version bump"

  printf "\n"
  git --no-pager show --stat HEAD
  printf "\n"
  confirm "Push $DEV_BRANCH to origin to trigger the dev pipeline?" \
    || fail "Aborted before push. Local commit is on $DEV_BRANCH."

  git push origin "$DEV_BRANCH"
  ok "Pushed $DEV_BRANCH — dev pipeline triggered."
}

deploy_staging() {
  printf "\n%s== STAGING deployment ==%s\n" "$C_BOLD" "$C_RESET"
  checkout_fresh "$STAGING_BRANCH"
  merge_main_into_current "$STAGING_BRANCH"

  local new_version semver build tag
  new_version="$(bump_build_number version_staging)"
  semver="${new_version%+*}"
  build="${new_version##*+}"
  tag="v${semver}-staging.${build}"
  ok "Bumped version_staging → $new_version"
  ok "Prerelease tag will be: $tag"

  git add "$PUBSPEC"
  git commit -m "chore(release): bump staging version to $new_version" >/dev/null
  ok "Committed version bump"

  printf "\n"
  git --no-pager show --stat HEAD
  printf "\n"
  confirm "Push $STAGING_BRANCH and publish prerelease $tag?" \
    || fail "Aborted before push. Local commit is on $STAGING_BRANCH."

  git push origin "$STAGING_BRANCH"
  ok "Pushed $STAGING_BRANCH"

  info "Creating prerelease $tag"
  gh release create "$tag" \
    --target "$STAGING_BRANCH" \
    --title "$tag" \
    --prerelease \
    --generate-notes
  ok "Prerelease $tag published — staging pipeline triggered."
}

# --- main ---

usage() {
  cat <<EOF
Usage: $0 {dev|staging|both}

  dev       Merge origin/main into $DEV_BRANCH, bump 'version', push.
  staging   Merge origin/main into $STAGING_BRANCH, bump 'version_staging',
            push, publish prerelease v{semver}-staging.{build}.
  both      Run dev, then staging.
EOF
}

[ $# -eq 1 ] || { usage; exit 1; }

ORIG_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
trap 'git checkout "$ORIG_BRANCH" >/dev/null 2>&1 || true' EXIT

case "$1" in
  dev)     preflight; deploy_dev ;;
  staging) preflight; deploy_staging ;;
  both)    preflight; deploy_dev; deploy_staging ;;
  -h|--help) usage ;;
  *)       usage; exit 1 ;;
esac

printf "\n%sDone.%s Returning to %s.\n" "$C_GREEN" "$C_RESET" "$ORIG_BRANCH"
