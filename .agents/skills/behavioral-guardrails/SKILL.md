---
name: behavioral-guardrails
description: Behavioral guidelines for Flutter base tasks: clarify ambiguity, keep changes simple and surgical, and define verifiable success criteria before coding.
license: MIT
compatibility: all
metadata:
  audience: ai-coding-agents
  framework: flutter
  pattern: behavioral-guidelines
---

# Behavioral Guardrails

Use this skill when writing, reviewing, refactoring, or planning code in the Flutter base template. It adapts the reusable ideas from the Karpathy-inspired `claude-skills` project to this repo's conventions.

**Tradeoff:** these guardrails bias toward caution over speed. For trivial one-line fixes, use judgment.

## 1. Think before coding

Do not silently choose an interpretation when the request is ambiguous.

Before implementing:

- State assumptions when they affect the code shape, generated files, external IDs, or user-visible behavior.
- Ask before changing package IDs, bundle IDs, signing paths, CI/CD, generated workflows, or broad formatting.
- If multiple implementation paths are plausible, present the main tradeoff briefly.
- Push back when a smaller repo-native approach exists.
- Stop and ask when project patterns conflict or a required source of truth is unclear.

Flutter base examples:

- Rebrand requests need display name vs technical identifier clarification.
- Localization requests need target locales and translation source clarified.
- New feature requests should use `module-scaffold`, `bloc-pattern`, and `route-config` rather than ad-hoc Flutter structure.

## 2. Simplicity first

Write the minimum code that solves the current request.

- No speculative features, flags, adapters, or abstractions.
- No new widget when an existing `fl_ui`, `core`, or module widget fits.
- No custom BLoC/state shape; use the repo `bloc-pattern`.
- No custom localization flow; update CSV and run `make lang`.
- No direct generated-file edits when a generator exists.

The test: if the same behavior can be expressed with an existing helper or pattern, reuse it.

## 3. Surgical changes

Every changed line should trace back to the user request or to a required generator output.

When editing:

- Do not reformat unrelated files unless the user asks or the formatter is intentionally part of the task.
- Do not refactor adjacent code while fixing a bug.
- Remove only imports/functions/files made unused by your change.
- Mention unrelated dead code or stale docs instead of deleting them.
- Keep generated output scoped to the package whose source inputs changed when possible.

If a command causes broad churn, pause and ask whether to keep or revert it.

## 4. Goal-driven execution

Turn each task into a verifiable outcome.

For multi-step work, track:

```text
1. Change source of truth → verify generated/config output
2. Update call sites → verify stale references are gone
3. Run targeted checks → verify analyzer/tests pass
```

Prefer concrete checks:

- `rg` for stale identifiers, locale codes, or old keys.
- `make lang` after localization CSV edits.
- `make gen_core`, `make gen_main`, or `make gen_all` only after relevant generated inputs change.
- `fvm flutter analyze --no-pub` from affected packages.
- UI smoke tests for user-facing flow changes when a device/browser is available.

## 5. Flutter base source-of-truth rules

Use these before editing derived files:

| Area | Source of truth | Regenerate/check |
|---|---|---|
| App IDs/display names | `apps/main/app_identifier.yaml` | `sh gen_app_identifier.sh apps/main` |
| App/core/media strings | `*/lib/l10n/localizations.csv` | `make lang` |
| BLoC `_StateData` / JSON / DI | annotated Dart files | `make gen_core`, `make gen_main`, or `make gen_all` |
| Theme tokens | `plugins/fl_theme/` and existing extensions | `fvm flutter analyze --no-pub` |
| Navigation | `IRoute`, `CustomRouter`, coordinators | route-config checklist |

## Checklist

- [ ] Ambiguity clarified before edits.
- [ ] Existing repo skill/pattern reused.
- [ ] No speculative abstraction or drive-by refactor.
- [ ] Generated files updated only via the proper generator.
- [ ] Stale references searched after rename/localization work.
- [ ] Targeted analyzer/tests run or explicitly reported as not run.
- [ ] Any broad formatter/generator churn was approved or reverted.

## Related

- [`module-scaffold`](../module-scaffold/SKILL.md)
- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`route-config`](../route-config/SKILL.md)
- [`localization`](../localization/SKILL.md)
- [`code-generation`](../code-generation/SKILL.md)
- [`flutter-reviewer`](../flutter-reviewer/SKILL.md)
