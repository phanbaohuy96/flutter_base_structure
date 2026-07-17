## Unreleased

* **Breaking — pruned cold widgets:** removed after confirming zero references
  across the repo (production, storybook, previews, tests): `HidableBottomNav`,
  `ShimmerWrapper`, `KeepAliveWidget`, `ViewMoreWidget`. Forks depending on any
  of these should vendor them from git history before upgrading.
* **Breaking — removed `CheckboxWithTitle`/`CheckBoxGroup`/`RadioButtonWithTitle`/`FlRadioGroup`:**
  storybook/preview/test-only, zero production consumers. Forks depending on
  these should vendor them from git history before upgrading.
* **Breaking — `Separator.color` is now nullable:** omitting it resolves the
  rendered separator color from `context.themeColor.dividerColor` instead of
  hardcoding black. Downstream code that reads the public property must handle
  `null`.

## 0.0.1

* TODO: Describe initial release.
