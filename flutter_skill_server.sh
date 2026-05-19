#!/usr/bin/env bash
# MCP stdio server entry point: stdout is JSON-RPC and must stay clean,
# so we suppress flutter_command.sh's progress echoes.
set -euo pipefail
cd "$(dirname "$0")"
# shellcheck disable=SC1091
source ./flutter_command.sh >/dev/null
setup_flutter_command >/dev/null
if [[ "${USING_FVM:-0}" == "1" ]]; then
  export PATH="$PWD/.fvm/flutter_sdk/bin:$PATH"
fi
exec npx -y flutter-skill@0.9.34 server "$@"
