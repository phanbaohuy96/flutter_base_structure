## Summary

<!-- One-line description of what this PR does -->

## Changes

- <!-- List specific changes, one per bullet -->

## Checklist

- [ ] Code follows project conventions (BLoC pattern, StateBase, CoreBlocBase, freezed _StateData)
- [ ] Import ordering follows project convention (SDK → external → project → relative → part)
- [ ] Localization CSV updated (English + Vietnamese) if UI strings changed
- [ ] `make lang` run if CSV changed
- [ ] `make gen_all` (or narrowed scope: `gen_core` / `gen_main` / `gen_data_source`) run if generated inputs changed
- [ ] Barrel exports regenerated if module/plugin files added or removed
- [ ] Route provider registered or interceptor updated if new route added
- [ ] `make pub_get` run if `pubspec.yaml` changed
- [ ] `make format` applied
- [ ] Analyzer passes for affected package(s), for example `make analyze PACKAGES="apps/main core"` or full `make analyze`
- [ ] Tests added/updated for new behavior
- [ ] Existing tests pass for affected package(s), for example `make test PACKAGES="apps/main core"` or full `make test`

## ⚠️ Caution items

- [ ] Distribution/signing changes reviewed (`app_identifier.yaml`, bundle IDs, keystores, Fastfile)
- [ ] `.agents/skills/` checked for relevant pattern guidance (e.g., fl-bloc-pattern, fl-data-layer, fl-localization)

## Screenshots (if UI change)

| Before | After |
|--------|-------|
|        |       |

## Notes

<!-- Anything reviewers should know: edge cases, design decisions, follow-ups -->
