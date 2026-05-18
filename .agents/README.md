# Agent Skills

Project-local skills for AI coding agents working in this Flutter base
template. Drop the whole `.agents/` directory into a forked app and the
skills travel with it.

These skills target the standard `.agents/skills/` location used by
OpenCode, Claude Code, Cursor, GitHub Copilot, Windsurf, and others.

## Quick links

- [`INDEX.md`](./INDEX.md) — one-line summary of every skill
- [`ONBOARDING.md`](./ONBOARDING.md) — orientation for new collaborators
- [`TROUBLESHOOTING.md`](./TROUBLESHOOTING.md) — common failure modes

## Skills

| Skill | What it covers |
|---|---|
| [`module-scaffold`](./skills/module-scaffold/SKILL.md) | Scaffold a feature module via `make run_module_generator` or by hand |
| [`bloc-pattern`](./skills/bloc-pattern/SKILL.md) | `AppBlocBase` + abstract state hierarchy + freezed `_StateData` |
| [`extension-action`](./skills/extension-action/SKILL.md) | `*.action.dart` part-of screen for handlers + bloc listeners |
| [`route-config`](./skills/route-config/SKILL.md) | `IRoute` / `CustomRouter` (from core) + `BuildContext` coordinator |
| [`theme-usage`](./skills/theme-usage/SKILL.md) | `context.themeColor` + `context.textTheme` from fl_theme |
| [`data-layer`](./skills/data-layer/SKILL.md) | Freezed DTO + Retrofit + hive_ce + repository wired through injectable |
| [`error-handling`](./skills/error-handling/SKILL.md) | Throw → `CoreBlocBase.onError` → `StateBase` `ErrorType` router |
| [`localization`](./skills/localization/SKILL.md) | CSV → ARB → generated `AppLocalizations` |
| [`code-generation`](./skills/code-generation/SKILL.md) | `make gen_all` / `make gen_<scope>` / `make lang` |
| [`testing`](./skills/testing/SKILL.md) | bloc_test + mocktail patterns; `flutter test` / `make coverage_main` |
| [`data-reviewer`](./skills/data-reviewer/SKILL.md) | Review checklist for data-layer diffs |
| [`flutter-reviewer`](./skills/flutter-reviewer/SKILL.md) | Review checklist for UI-layer diffs |

## Conventions enforced

These skills assume the structure shipped by the template:

- Clean architecture: `presentation/` → `domain/` → `data/`.
- BLoC via `flutter_bloc` + `bloc_concurrency`, with the `_StateData`
  pattern + `_factories` map (not freezed sealed unions).
- Routing via `IRoute` + `CustomRouter` from `core/lib/presentation/route/`
  (re-exported via `package:core/core.dart`).
- Theming via `plugins/fl_theme/` — Material 3 token names plus
  `AppTextTheme` extras; reach colors with `context.themeColor`.
- Localization via CSV in `apps/main/lib/l10n/localizations.csv`,
  generated with `make lang`.
- Code generation orchestrated through the makefile (`make gen_all`).

## Skill structure

```
skills/
└── <name>/
    └── SKILL.md
```

Each `SKILL.md` opens with frontmatter:

```yaml
---
name: <name>
description: <one-line summary, ≤1024 chars>
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
---
```

Followed by sections: **When to use**, the conventions or patterns to
enforce, references with file paths, and a checklist.

## Adding a new skill

1. `mkdir .agents/skills/<name>` and add `SKILL.md`.
2. Document the rule, not the symptom — explain when the skill applies
   and what it enforces.
3. Cross-reference related skills under a `## Related` heading.
4. Update [`INDEX.md`](./INDEX.md) with one line for the new skill.
5. Run a real task through it to validate.

## Team configuration

Agent roles for this template are declared in
[`teams/development-team.yaml`](./teams/development-team.yaml).
