#!/usr/bin/env python3
import argparse
import re
import sys
from pathlib import Path

SKIP_DIRS = {
    ".dart_tool",
    ".fvm",
    ".git",
    ".pub-cache",
    "Pods",
    "build",
    "coverage",
}

GENERATED_SUFFIXES = (
    ".config.dart",
    ".freezed.dart",
    ".g.dart",
    ".gr.dart",
)

ALLOWED_PATH_PARTS = (
    "/di/",
    "/test/",
    "/integration_test/",
)

ALLOWED_FILES = {
    "app.dart",
    "app_delegate.dart",
    "main.dart",
    "main_dev.dart",
    "main_sandbox.dart",
    "main_staging.dart",
}

ALLOWED_SUFFIXES = (
    "_route.dart",
    "_router.dart",
    "route.dart",
    "router.dart",
)

BASELINE_FILES = {
    "core/lib/common/utils/log_utils.dart",
    "core/lib/presentation/extentions/dialog_extention.dart",
}

LOCATOR_PATTERNS = (
    (re.compile(r"\bGetIt\.(?:instance|I|asNewInstance)\b"), "direct GetIt access"),
    (re.compile(r"\binjector\s*<"), "direct injector<T>() access"),
    (re.compile(r"\bgetIt\s*<"), "direct getIt<T>() access"),
)

GET_IT_IMPORT_RE = re.compile(r"import\s+['\"]package:get_it/get_it\.dart['\"]")
DI_ANNOTATION_RE = re.compile(
    r"@\s*(?:InjectableInit|Injectable|injectable|lazySingleton|singleton|module|factoryParam|preResolve|Named|Environment)\b"
)


def is_generated(path: Path) -> bool:
    name = path.name
    return any(name.endswith(suffix) for suffix in GENERATED_SUFFIXES)


def is_allowed_locator_path(path: Path) -> bool:
    normalized = path.as_posix()
    return (
        path.name in ALLOWED_FILES
        or path.name.endswith(ALLOWED_SUFFIXES)
        or any(part in normalized for part in ALLOWED_PATH_PARTS)
    )


def rel(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def iter_dart_files(root: Path, scopes: list[str]):
    roots = scopes or ["."]
    seen = set()
    for scope in roots:
        scan_root = (root / scope).resolve()
        candidates = [scan_root] if scan_root.is_file() else scan_root.rglob("*.dart")
        for path in candidates:
            if path in seen:
                continue
            seen.add(path)
            if path.suffix != ".dart":
                continue
            if any(part in SKIP_DIRS for part in path.parts):
                continue
            if is_generated(path):
                continue
            yield path


def scan_file(path: Path, root: Path, include_baseline: bool):
    warnings = []
    has_annotation = False
    relative = rel(path, root)
    allowed = is_allowed_locator_path(path)
    baseline_allowed = relative in BASELINE_FILES and not include_baseline

    try:
        with path.open(encoding="utf-8", errors="ignore") as source:
            for line_number, line in enumerate(source, start=1):
                if DI_ANNOTATION_RE.search(line):
                    has_annotation = True

                if baseline_allowed or allowed:
                    continue

                if GET_IT_IMPORT_RE.search(line):
                    warnings.append(
                        f"{relative}:{line_number}: get_it imported outside a likely composition boundary"
                    )

                for pattern, label in LOCATOR_PATTERNS:
                    if pattern.search(line):
                        warnings.append(f"{relative}:{line_number}: {label}")
    except OSError as error:
        warnings.append(f"{relative}: unable to read file: {error}")

    return warnings, has_annotation


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check Flutter/Dart Injectable + GetIt usage for common DI review signals."
    )
    parser.add_argument("root", nargs="?", default=".", help="Repository root to scan")
    parser.add_argument(
        "--scope",
        action="append",
        default=[],
        help="Relative file or directory to scan. Can be passed multiple times.",
    )
    parser.add_argument(
        "--include-baseline",
        action="store_true",
        help="Include known existing locator warnings that are intentionally excluded by default.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit 1 when warnings are found",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not root.exists():
        print(f"error: root does not exist: {root}", file=sys.stderr)
        return 2

    warnings = []
    annotation_count = 0

    for path in iter_dart_files(root, args.scope):
        file_warnings, has_annotation = scan_file(path, root, args.include_baseline)
        warnings.extend(file_warnings)
        if has_annotation:
            annotation_count += 1

    if warnings:
        print("DI usage warnings:")
        for warning in warnings:
            print(f"- {warning}")
    else:
        print("No direct GetIt/service-locator warnings found.")

    if annotation_count:
        print(
            f"DI annotations found in {annotation_count} source files. "
            "After changing them, run the narrowest project generator."
        )

    return 1 if warnings and args.strict else 0


if __name__ == "__main__":
    raise SystemExit(main())
