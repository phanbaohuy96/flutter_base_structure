## Unreleased

* **Breaking — pruned cold widgets:** removed after confirming zero references
  across the repo (production, storybook, previews, tests): `HidableBottomNav`,
  `ShimmerWrapper`, `KeepAliveWidget`, `ViewMoreWidget`. Forks depending on any
  of these should vendor them from git history before upgrading.
* **Breaking — removed `CheckboxWithTitle`/`CheckBoxGroup`/`RadioButtonWithTitle`/`FlRadioGroup`:**
  storybook/preview/test-only, zero production consumers. Forks depending on
  these should vendor them from git history before upgrading.

## 0.0.1

* TODO: Describe initial release.
