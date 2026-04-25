---
name: code-generation
description: Runs build_runner across core, data_source, and apps/main via the makefile after edits to freezed/injectable/retrofit/hive sources
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: code-generation
---

# Code Generation Skill

## When to use

After editing any file annotated with `@freezed`, `@JsonSerializable`/`@JsonKey`, `@Injectable`/`@LazySingleton`/`@Singleton`/`@module`, `@RestApi`, `@HiveType`, or that declares a `_StateData` for a bloc.

## Commands

The makefile is the canonical interface. It auto-detects `fvm` if present and falls back to the system Flutter SDK.

| Command | What it runs |
|---|---|
| `make gen_all` | `gen_core` → `gen_data_source` → `gen_main` (full graph) |
| `make gen_main` | `build_runner build` only inside `apps/main/` |
| `make gen_core` | `build_runner build` only inside `core/` |
| `make gen_data_source` | `build_runner build` only inside `modules/data_source/` |
| `make gen` | Interactive picker for the same targets |
| `make lang` | Regenerates `app_localizations_*.dart` from `localizations.csv` |
| `make asset` | Regenerates the asset accessor under each package |
| `make format` | `dart format .` across the repo |
| `make pub_get` | `pub get` across plugins, core, main |

When you don't know the scope of your change, run `make gen_all`. It's slower but never wrong.

## Generated files

| Pattern | Producer | Hand-edit? |
|---|---|---|
| `*.freezed.dart` | freezed | Never |
| `*.g.dart` | json_serializable, retrofit, hive_ce | Never |
| `*.config.dart` | injectable | Never |
| `app_localizations*.dart` | flutter intl tooling via `make lang` | Never |

All generated files **are** committed to source control — CI does not regenerate them.

## When generation fails

1. **Stale cache** — `dart run build_runner clean` from inside the failing package, then re-run `make gen_<scope>`.
2. **Missing `part` directive** — every freezed/json/retrofit source needs the matching `part 'foo.freezed.dart';` / `part 'foo.g.dart';`.
3. **Missing `sealed`** — freezed unions and the bloc `_StateData` require `sealed class`.
4. **Missing `@Default(...)`** — non-nullable fields without a default break codegen.
5. **Conflicting outputs** — the makefile already passes `--delete-conflicting-outputs`; if you're invoking `dart run build_runner` directly, do the same.

## Watch mode

Useful while iterating on a single package:

```bash
cd apps/main
fvm dart run build_runner watch --delete-conflicting-outputs   # or `dart run …` if no fvm
```

Stop with Ctrl-C. Don't leave it running in CI.

## CI hook

For a pre-commit/CI gate, run `make gen_all` and then assert that no generated artifacts changed:

```bash
make gen_all
git diff --exit-code -- '**/*.freezed.dart' '**/*.g.dart' '**/*.config.dart' \
  'apps/main/lib/l10n/generated/**'
```

## Checklist

- [ ] After adding/changing a `@freezed`/`@Injectable`/`@RestApi`/`@HiveType` source, `make gen_all` (or the narrow target) was run.
- [ ] After editing `localizations.csv`, `make lang` was run.
- [ ] No hand-edited generated files in the diff.
- [ ] All generated files are staged for commit.

## Common mistakes

- Running `dart run build_runner build` without `--delete-conflicting-outputs` and stopping at the first conflict.
- Editing `*.freezed.dart` to silence an analyzer warning — fix the source instead.
- Forgetting that `make gen_main` does *not* touch `core/` or `modules/data_source/`. When core types change, run `make gen_all`.

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`data-layer`](../data-layer/SKILL.md)
- [`module-scaffold`](../module-scaffold/SKILL.md)
