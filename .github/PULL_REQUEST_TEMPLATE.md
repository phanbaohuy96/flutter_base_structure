<!--
Delete any section or checklist block that doesn't apply — an empty heading is noise for the reviewer.

Convention review (BLoC shape, StateBase, theming tokens, import ordering, performance) is not
duplicated here: the analyzer enforces it and `.agents/skills/fl-reviewer` covers the rest in detail.
This template is for what you did and what the reviewer needs to know.
-->

## Summary

<!-- What changes and why, in a sentence or two. Link the issue if there is one: Closes #123 -->

## Changes

- <!-- One bullet per change. Lead with the behavior, not the filename. -->

## Verification

<!-- Paste the commands you actually ran, not the ones you meant to. CI runs `make check` too. -->

```bash
make check
```

## Checklist

- [ ] `make check` is green — analyzer, `format_check`, and tests across every package. Analyzer **infos** fail this gate too; fix them by hand, never with `dart fix --apply`.
- [ ] Tests added or updated for new behavior
- [ ] No secrets committed — `.env`, keystores, tokens, provisioning profiles

<details>
<summary>Touched generated inputs, localization, routes, or dependencies</summary>

- [ ] `make lang` run — localization CSVs changed (English **and** Vietnamese)
- [ ] `make gen_core` / `gen_data_source` / `gen_main` (or `gen_all`) run — Freezed, `@JsonSerializable`, Injectable, or route inputs changed
- [ ] Barrel exports regenerated — module or plugin files added/removed
- [ ] Route provider registered or interceptor updated — new route added
- [ ] `make pub_get` run and lockfiles committed — `pubspec.yaml` changed
- [ ] Generated files were regenerated, not hand-edited

</details>

<details>
<summary>Touched the template surface that downstream projects consume</summary>

<!-- This repo is a template: `make create_project` copies it into real apps, so these changes ripple outward. -->

- [ ] `make verify_module_generator` passes — `tools/module_generator` changed.
      ⚠️ Stash or commit untracked work first: the smoke gate's exit trap `rm -rf`s its scratch
      paths and restores regenerated files from git, so untracked files there are destroyed.
- [ ] `AGENTS.md`, `README.md`, and `.agents/skills/` updated to match the new behavior
- [ ] `CONTEXT.md` updated, or an ADR added under `docs/adr/` — a domain term or architectural decision changed
- [ ] Migration note for already-generated projects included in Notes below

</details>

<details>
<summary>⚠️ Distribution, signing, or runtime security</summary>

<!-- These reach Firebase, Apple Developer, Play Console, and CI. Call them out explicitly. -->

- [ ] Reviewed: `apps/main/app_identifier.yaml`, bundle IDs, `apps/main/dist_config.sh`, `distribution.sh`, `apps/main/fastlane/Fastfile`, iOS xcconfigs, `apps/main/ios/signing_res/`, `apps/main/android/keystores/`
- [ ] Reviewed: cleartext-traffic defaults, `allowBackup` / `fullBackupContent` / `dataExtractionRules`, MCP server pinning, network-logging and cURL-export defaults

</details>

## Screenshots

<!--
UI changes only — delete otherwise. Note the platform and flavor per row.
Add rows for dark theme (`fl_theme`) and the `vi` locale when either is affected.
-->

| Platform / flavor | Before | After |
|---|---|---|
|  |  |  |

## Notes for the reviewer

<!--
Where to start reading, edge cases, decisions worth pushing back on,
and anything you deliberately left as a follow-up.
-->
