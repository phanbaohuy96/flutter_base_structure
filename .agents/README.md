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
| [`fl-behavioral-guardrails`](./skills/fl-behavioral-guardrails/SKILL.md) | Clarify ambiguity, avoid overengineering, keep diffs surgical, verify outcomes |
| [`fl-module-scaffold`](./skills/fl-module-scaffold/SKILL.md) | Scaffold a feature module via `make run_module_generator` or by hand |
| [`fl-bloc-pattern`](./skills/fl-bloc-pattern/SKILL.md) | `CoreBlocBase` + abstract state hierarchy + freezed `_StateData` |
| [`fl-bus-event`](./skills/fl-bus-event/SKILL.md) | Cross-feature synchronization with `EventBusManager` |
| [`fl-extension-action`](./skills/fl-extension-action/SKILL.md) | `*.action.dart` part-of screen for handlers + bloc listeners |
| [`fl-route-config`](./skills/fl-route-config/SKILL.md) | `IRoute` / `CustomRouter` (from core) + `BuildContext` coordinator |
| [`fl-theme-usage`](./skills/fl-theme-usage/SKILL.md) | `context.themeColor` + `context.textTheme` from fl_theme |
| [`fl-ui-components`](./skills/fl-ui-components/SKILL.md) | Awareness index of reusable widgets across `fl_ui`, `fl_theme`, `fl_media`, and `common_widget` |
| [`fl-widget-preview`](./skills/fl-widget-preview/SKILL.md) | Official Flutter Widget Previewer with `@Preview` and `flutter widget-preview start` |
| [`fl-data-layer`](./skills/fl-data-layer/SKILL.md) | Freezed DTO + Retrofit + storage seam + repository wired through injectable (Hive optional) |
| [`fl-dependency-injection`](./skills/fl-dependency-injection/SKILL.md) | Injectable + GetIt boundaries, lifetimes, contracts, codegen, and DI tests |
| [`fl-error-handling`](./skills/fl-error-handling/SKILL.md) | Throw → `CoreBlocBase.onError` → `StateBase` `ErrorType` router |
| [`fl-localization`](./skills/fl-localization/SKILL.md) | CSV → ARB → generated `AppLocalizations` |
| [`fl-code-generation`](./skills/fl-code-generation/SKILL.md) | `make gen_all` / `make gen_<scope>` / `make lang` |
| [`fl-testing`](./skills/fl-testing/SKILL.md) | bloc_test + mocktail patterns; `flutter test` / `make coverage_main` |
| [`fl-data-reviewer`](./skills/fl-data-reviewer/SKILL.md) | Review checklist for data-layer diffs |
| [`fl-reviewer`](./skills/fl-reviewer/SKILL.md) | Review checklist for UI-layer diffs |

## Conventions enforced

These skills assume the structure shipped by the template:

- Behavioral guardrails from `fl-behavioral-guardrails`: clarify ambiguity, keep changes simple, avoid unrelated churn, and verify outcomes.
- Clean architecture: `presentation/` → `domain/` → `data/`.
- BLoC via `flutter_bloc` + `bloc_concurrency`, with the `_StateData`
  pattern + `_factories` map (not freezed sealed unions).
- Cross-feature synchronization via `BusEvent` + `EventBusManager`.
- Routing via `IRoute` + `CustomRouter` from `core/lib/presentation/route/`
  (re-exported via `package:core/core.dart`).
- Local persistence via the storage seam (`CoreLocalDataManager` /
  `LocalDataManager`) — never raw `SharedPreferences` / `FlutterSecureStorage`.
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
