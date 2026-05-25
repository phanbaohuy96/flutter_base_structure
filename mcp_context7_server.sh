#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ ! -x ./node_modules/.bin/context7-mcp ]]; then
  npm ci --ignore-scripts --no-audit --no-fund >&2
fi
exec ./node_modules/.bin/context7-mcp "$@"
