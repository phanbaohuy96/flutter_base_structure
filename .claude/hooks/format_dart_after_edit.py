#!/usr/bin/env python3
import json
import os
import subprocess
import sys


def _tool_path(payload):
    tool_input = payload.get("tool_input") or {}
    tool_response = payload.get("tool_response") or {}
    return (
        tool_response.get("filePath")
        or tool_response.get("file_path")
        or tool_input.get("file_path")
        or ""
    )


def _is_generated(path):
    normalized = path.replace(os.sep, "/")
    name = os.path.basename(normalized)
    return (
        name.endswith((".g.dart", ".freezed.dart", ".config.dart", ".module.dart"))
        or "/lib/generated/" in normalized
        or "/lib/l10n/generated/" in normalized
        or "/lib/src/l10n/generated/" in normalized
    )


try:
    payload = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

file_path = _tool_path(payload)
if not file_path.endswith(".dart") or _is_generated(file_path):
    sys.exit(0)

root_result = subprocess.run(
    ["git", "rev-parse", "--show-toplevel"],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,
    text=True,
    check=False,
)
repo_root = root_result.stdout.strip() or os.getcwd()

result = subprocess.run(["make", "-C", repo_root, "format"], check=False)
sys.exit(result.returncode)
