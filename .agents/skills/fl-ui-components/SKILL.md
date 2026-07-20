---
name: fl-ui-components
description: Awareness index of every reusable widget in fl_ui, fl_theme, fl_media, and core's common_widget — name, one-line purpose, when to reach for it instead of writing a new one
license: MIT
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: component-reuse
---

# UI Components Skill

## When to use

- Before writing any new widget, form field, dialog, or list/media control.
- Reviewing a diff against `fl-reviewer`'s red flag: "a custom control recreated when an existing project widget already fits."

## What this template ships

Everything below is reachable from a single `import 'package:core/core.dart';` — it re-exports `plugins/fl_ui`, `plugins/fl_theme`, `plugins/fl_media`, and `core/lib/presentation/common_widget/`.

This is an **awareness index, not an API reference** — once you've picked a widget, use IDE autocomplete or CodeGraph for exact constructor params instead of memorizing them (same approach as `fl-theme-usage`).

Two live catalogs demo a chunk of this inventory interactively:

- In-app storybook: `core/lib/presentation/modules/dev_mode/design_system/` → `/dev-mode-design-system` route.
- Widget-preview gallery: `plugins/fl_ui/lib/fl_ui_previews.dart` (`flutter widget-preview start` — see `fl-widget-preview`).

## Expensive: never rebuild these

Large, non-trivial, or vendored — reimplementing any of these from scratch is a multi-hundred-line mistake.

| Widget | LOC | Why it's expensive |
|---|---|---|
| `date_picker/` cluster | ~4.6k | Vendored fork (`flutter_datetime_picker` + Cupertino + calendar variants). Only `showMyCustomDatePicker` is wired into the storybook demo — check the directory directly before assuming another entry point is exercised. |
| `MediaPickerWidget` | 1072 | Full picker UI — selection, preview, multi-select management — built on top of `PickFileHelper`. |
| `MediaViewerWidget` | 541 | Full-screen photo/video viewer with gallery paging, zoom, and hero transitions (`fl_media`). |
| `SliverGroupBuilder` (`group_sliver/`) | ~430 | Custom `RenderSliver` for grouped/sticky-header sliver lists — reimplementing sliver protocol internals from scratch is not worth it. |
| `InputContainer` | 516 | Every themed text field in the app — label, border states, validation, tagging (+237 in `TextTaggingController`). |
| `VideoControllerManager` | 476 | Video controller lifecycle (init/dispose/buffering) — don't hand-roll `VideoPlayerController` management. |
| `ScreenForm` | 355 | Standard screen chrome — app bar, scaffold content, keyboard avoidance. See `fl-theme-usage`. |
| `MultipleChoiceDropdownWidget` | 369 | Multi-select dropdown with chips. |
| `ImageView` | 347 | Themed image display with loading/error states and provider selection (`fl_media`). |
| `DropdownWidget` | 265 | Single-select dropdown, themed. |

## Screens & layout

| Widget | Use it for |
|---|---|
| `ScreenForm` | Standard screen wrapper (app bar + scaffold content + keyboard avoidance). |
| `MainPageForm` | Wrapper for main-tab pages. |
| `BottomBorderDecoration` | App bar bottom border (`forms/appbar_decoration.dart`). |
| `LayoutSwitching` | Animated switch between two layouts. |
| `MeasureSize` | Report a child's rendered size after layout. |
| `TextScaleFixed` | Lock text scale factor for a subtree. |
| `ExpandableWidget` | Expand/collapse a single child. |
| `ExpandableWidgetList` | Expand/collapse a list of children. |

## Text input

| Widget | Use it for |
|---|---|
| `InputContainer` | Themed text field — label, border states, validation, tagging. |
| `FakeInputField` | Read-only, input-styled tap target (opens a picker/dialog instead of typing). |
| `TextTaggingController` | `TextEditingController` that tracks @mention/tag spans. |
| `InputDecorationFactory` | Shared `InputDecoration` builder (`TitleMode.floating` / `.above`). |
| `InputTitleWidget` / `InputHelperError` | Label above an input / helper-or-error text below it. |

## Selection

| Widget | Use it for |
|---|---|
| `DropdownWidget<T>` | Single-select dropdown. |
| `MultipleChoiceDropdownWidget<T>` | Multi-select dropdown with chips. |
| `DropdownMenuButton<T>` | Menu-button-style dropdown trigger. |
| `ChipItem` | Selectable chip. |

## Buttons

| Widget | Use it for |
|---|---|
| `ThemeButton.*` | Default button styling — see `fl-theme-usage`. Prefer this over any new button widget. |
| `AnimatedDropdownIcon` | Animated chevron for expand/collapse triggers. |
| `EnViSwitch` | EN/VI locale toggle button. |
| `VerticalStepper` / `StepData` / `AnimatedSlideBox` | Multi-step vertical flow indicator. |

## Dates

| Widget | Use it for |
|---|---|
| `date_picker/` cluster | Vendored date/time picker fork — see "Expensive" above. Check the directory before adding a new date-picking dependency. |

## Feedback & empty states

| Widget | Use it for |
|---|---|
| `Loading` | Spinner (paired with `showLoading()`/`hideLoading()` — see `fl-bloc-pattern`). |
| `ErrorBox` / `ErrorBoxController` | Wrap a field to show a validation error. |
| `AvailabilityWidget` | Dim/disable a child when unavailable. |
| `EmptyData` | Empty-state placeholder. |
| `BadgeBox` | Notification-count badge. |
| `StatusBox` | Status pill (e.g. "Active", "Pending"). |
| `UnsupportedPage` | Placeholder for an unsupported platform/route. |

## Dialogs

All from `core/lib/presentation/extentions/dialog_extention.dart` — call directly on a `BuildContext`, don't build a new `AlertDialog`.

| Helper | Use it for |
|---|---|
| `showNoticeDialog` | Simple info notice. |
| `showNoticeErrorDialog` / `showNoticeWarningDialog` | Error/warning notice. |
| `showNoticeConfirmDialog` | Yes/no confirmation. |
| `showNoticeConfirmWithReasonDialog` | Confirmation that collects a free-text reason. |
| `showNoticeConfirmWithValidateDialog` | Confirmation with a validated input. |
| `showActionDialog` | Action sheet / list of choices. |
| `showModal` | Generic modal host for custom content. |

## Lists & scroll

| Widget | Use it for |
|---|---|
| `SmartRefresherWrapper` + `RefreshController` | Pull-to-refresh / load-more list — scaffolded into every generated listing/detail module. |
| `SliverGroupBuilder` (`group_sliver/`) | Grouped sliver list with sticky section headers — see "Expensive" above. |
| `MobileLikeScrollBehavior` | Allow scroll views to be dragged with touch or a mouse. |
| `StoryWidgetBox<T>` | Labeled preview/story container (storybook infra). |

## Media

| Widget | Use it for |
|---|---|
| `MediaViewerWidget` + `MediaViewerController` / `MediaViewerItem` | Full-screen photo/video viewer with paging and zoom. |
| `ImageView` / `ImageViewWrapper` | Themed image display with loading/error states. |
| `ExtendedNetworkImage` / `ImageViewProviderFactory` | Lower-level image-provider building blocks behind `ImageView`. |
| `ImageGalleryWidget` | Full-screen swipeable image pager. |
| `ImageZoom` | Pinch-to-zoom wrapper. |
| `HeroWidget` | Hero-animated media transition. |
| `VideoControllerManager` | Video controller lifecycle — see "Expensive" above. |
| `VideoControllerWrapper` / `LocalVideoSource` / `NetworkVideoSource` | Video source/config plumbing for the controller manager. |
| `VideoViewerWidget` | Embeddable video viewer with playback controls and swipe-to-dismiss support. |
| `VideoViewerScreen` / `VideoViewerArgs` | Full video-viewer screen (route-ready). |
| `ImageCropperScreen` / `context.cropImage(...)` | Platform-adaptive image-cropping flow exposed through the `ImageCropperCoordinator`. |
| `MediaPickerWidget` + `MediaPickerController` / `MediaPickerConfig` / `MediaPickerStyle` | Full picker UI — selection, preview, multi-select — see "Expensive" above. |
| `PickFileHelper` (`FileType`) | Native file/media picker with no bundled UI — what `MediaPickerWidget` is built on; use directly for a headless pick. |
| `HorizontalImages` | Horizontal-scrolling row of images. |
| `HtmlWidgetWrapper` | Render HTML content (incl. embedded video via `CustomHTMLWidgetFactory`). |

## Info display

| Widget | Use it for |
|---|---|
| `InfoItem` | Label/value row with an optional divider (`ItemDivider`). |
| `MenuItemWidget` | Icon + title + description tappable row with optional `ItemBorder`. |
| `BoxColor` / `HighlightBoxColor` | Colored container / bordered highlight box. |
| `BannerWidget<T>` / `BannerItem<T>` | Rotating banner/carousel (`BannerWidgetUIStyle`). |
| `ReceiptShapeBorder` | Zigzag receipt-style shape border. |
| `Separator` | Themed divider line — never a raw `Divider(color: Colors.black)`. |
| `FooterWidget` | List/screen footer. |

## Navigation

| Widget | Use it for |
|---|---|
| `CustomTabbar` / `TabItem` | Custom-styled tab bar. |
| `TabPageWidget` / `TabBox` | Tab-paged container. |
| `PageIndicatorWidget` | Dot page indicator (for `PageView`/carousels). |

## Utility

| Widget | Use it for |
|---|---|
| `AfterLayoutMixin<T>` | Run a callback after the first frame. |
| `TickerBuilder` | Rebuild on every animation tick without a full `AnimationController`. |

## Checklist

- [ ] Searched this index before writing a new widget, dialog, or list wrapper.
- [ ] Checked the storybook (`/dev-mode-design-system`) or `fl_ui_previews.dart` when unsure how something looks or behaves.
- [ ] Used IDE autocomplete/CodeGraph for exact constructor params — this index tracks *what exists*, not signatures.
- [ ] For dates specifically, checked `date_picker/` instead of adding a new date-picker package.

## Related

- [`fl-theme-usage`](../fl-theme-usage/SKILL.md)
- [`fl-reviewer`](../fl-reviewer/SKILL.md)
- [`fl-widget-preview`](../fl-widget-preview/SKILL.md)
- [`fl-module-scaffold`](../fl-module-scaffold/SKILL.md)
