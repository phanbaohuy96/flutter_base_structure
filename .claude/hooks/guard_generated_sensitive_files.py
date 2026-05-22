#!/usr/bin/env python3
import json
import os
import re
import sys


def _emit(decision, reason):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        },
    }))


def _relative_path(path):
    normalized = path.replace("\\", "/")
    if os.path.isabs(normalized):
        try:
            normalized = os.path.relpath(normalized, os.getcwd())
        except ValueError:
            pass
    return normalized.replace("\\", "/").lstrip("./")


def _matches(path, patterns):
    return any(re.search(pattern, path) for pattern in patterns)


try:
    payload = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

file_path = (payload.get("tool_input") or {}).get("file_path") or ""
if not file_path:
    sys.exit(0)

rel_path = _relative_path(file_path)
name = os.path.basename(rel_path)

deny_patterns = [
    r"(^|/)lib/generated/",
    r"(^|/)lib/l10n/generated/",
    r"(^|/)lib/src/l10n/generated/",
    r"(^|/)intl_[^/]*\.arb$",
    r"(^|/)(credentials|credential|secrets?|service-account)[^/]*\.(json|ya?ml|txt)$",
]

ask_patterns = [
    r"(^|/)app_identifier\.yaml$",
    r"(^|/)android/app_specific\.properties$",
    r"(^|/)android/app/build\.gradle$",
    r"(^|/)android/app/src/main/kotlin/.*/MainActivity\.kt$",
    r"(^|/)ios/Flutter/AppSpecific\.xcconfig$",
    r"(^|/)android/keystores/",
    r"(^|/)ios/signing_res/",
    r"(^|/)fastlane/",
    r"(^|/)dist_config\.sh$",
    r"(^|/)distribution\.sh$",
    r"(^|/)deploy\.sh$",
    r"(^|/)CICD_SECRETS_SETUP\.md$",
    r"(^|/)\.github/workflows/",
]

if name.endswith((".g.dart", ".freezed.dart", ".config.dart", ".module.dart")) or _matches(rel_path, deny_patterns):
    _emit(
        "deny",
        f"{rel_path} looks generated or secret-bearing. Edit the source of truth and run the appropriate generator instead.",
    )
    sys.exit(0)

if name == ".env" or (name.startswith(".env.") and name != ".env.example"):
    _emit("deny", f"{rel_path} is an environment file and may contain secrets.")
    sys.exit(0)

if name.endswith((".keystore", ".jks", ".p8", ".p12", ".mobileprovision", ".provisionprofile")):
    _emit("deny", f"{rel_path} is a signing credential or provisioning artifact.")
    sys.exit(0)

if _matches(rel_path, ask_patterns):
    _emit(
        "ask",
        f"{rel_path} affects app identity, signing, distribution, or CI. Confirm this high-blast-radius edit is intentional.",
    )
