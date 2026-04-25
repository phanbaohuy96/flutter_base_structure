---
name: error-handling
description: Routes thrown errors through CoreBlocBase + CoreDelegate to StateBase's ErrorType-driven dialog/snackbar/login UI rather than a custom Failure type
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: error-handling
---

# Error Handling Skill

## When to use

- Deciding what to do with a thrown error inside a bloc handler.
- Tweaking the user-facing message or routing for a specific error type.
- Adding bespoke recovery (silent retry, optimistic rollback, redirect) on top of the default UI.

## End-to-end flow

The bloc and the screen share a `CoreDelegate` mixin. The bloc *raises*
errors and loading; the screen *registers handlers* and renders them:

1. Throw inside a bloc handler → `CoreBlocBase.onError` converts via
   `ErrorData.fromObject` and calls `notifyError` (skipped if the throw
   is not an `Exception`/`Error`).
2. The screen registered `StateBase.onError` in `initState`, so it
   receives the `ErrorData`.
3. `StateBase` localizes Firebase codes, calls `hideLoading()`, dedupes
   on `errorTypeShowing == error.type`, computes `getErrorMsg`, then
   routes by `ErrorType`:

| `ErrorType` | UI |
|---|---|
| `unauthorized` | `showLoginRequired` → `backToAuth` |
| `badResponse` + 5xx | `showErrorDialog` |
| `badResponse` + 4xx | `onClientError` (default `showErrorDialog`) |
| `timeout` / `noInternet` | online: `showErrorDialog`; offline: `showNoInternetDialog` |
| `serverUnExpected` / `internalServerError` / `restricted` / `dataParsing` | `showErrorDialog` |
| anything else | dev: `showErrorDialog`; prod: log only |

Loading rides the same plumbing: `bloc.showLoading()` (inherited from
`CoreDelegate`) fans out to every registered screen, which calls its
own `showLoading()` (the EasyLoading wrapper on `CoreStateBase`). The
two methods deliberately share names — bloc-side is fan-out, screen-side
is the actual UI call.

## Pieces in `core/`

| File | What it provides |
|---|---|
| `core/lib/data/data_source/remote/api_service_error.dart` | `ErrorData`, `ErrorType` (`noInternet`, `timeout`, `unauthorized`, `unknown`, `badResponse`, `serverUnExpected`, `internalServerError`, `restricted`, `dataParsing`), `ErrorOrigin` (`dio`, `graphql`, `firebase`); `ErrorData.fromDio`, `.fromError`, `.fromException`, `.fromObject` |
| `core/lib/presentation/base/delegate.dart` | `CoreDelegate` mixin: `notifyError`, `addErrorHandler`/`removeErrorHandler`, `showLoading`/`hideLoading`, `addLoadingHandler`/`removeLoadingHandler`, `clear()` |
| `core/lib/presentation/base/bloc/bloc_base.dart` | `CoreBlocBase` mixes in `CoreDelegate`; overrides `onError` to convert + `notifyError`; calls `clear()` on `close()` |
| `core/lib/presentation/base/state_base/state_base.dart` | `CoreStateBase`: registers `onError` + `invokeLoading` against `delegate?` in `initState`; provides `showLoading`/`hideLoading` (EasyLoading), `showErrorDialog`, `showLoginRequired`, `showNoInternetDialog`, `onClientError`, `backToAuth`, `doLogout`, `loading` widget |
| `core/lib/presentation/base/state_base/state_base.error_handler.dart` | `_onError`, `_handleErrorByType`, `getErrorMsg` (overridable), `_connectivityErrorOrNot` |
| `apps/main/lib/presentation/base/state_base/state_base.dart` | App-level `StateBase`: overrides `delegate => bloc`, implements `backToAuth` to open sign-in, augments `doLogout` |

`ErrorData.fromDio` is the single most important reader: it parses the
response body through `ApiResponse`, pulls out `message` + `messageKey`,
maps `DioExceptionType` → `ErrorType`, and special-cases 401 / `invalidToken`
/ `userNotFound` → `unauthorized`.

## Default path: throw and let it route

Don't `try/catch` defensively. The framework wants the throw.

```dart
Future<void> _onSubmit(SubmitEvent event, Emitter<FeatureState> emit) async {
  showLoading();   // CoreDelegate — wakes every registered screen loader
  try {
    final receipt = await _usecase.submit(event.payload);
    emit(state.copyWith<FeatureSuccess>(
      data: state.data.copyWith(receipt: receipt),
    ));
  } finally {
    hideLoading();
  }
}
```

If `_usecase.submit` throws a `DioException`, `CoreBlocBase.onError`
catches it, converts to `ErrorData`, and the screen renders the right UI
without any explicit emit. Don't also `emit(...errorState)` afterwards —
the bloc may already have closed by the time the dialog is dismissed.

## When to catch

Catch only the case you can recover from in-handler. Let the rest fall
through.

```dart
try {
  await _usecase.submit(event.payload);
} on DioException catch (e) when (e.response?.statusCode == 409) {
  // Optimistic-merge conflict — silent re-fetch, no dialog.
  add(GetFeatureEvent(event.id));
  return;
}
// Any other exception bubbles to CoreBlocBase.onError.
```

For domain-level "soft" failures (a login form rejecting bad credentials
inline, a stale optimistic update), emit a state — don't throw. Throws
are for things that should pop a dialog the user has to acknowledge.

## Customizing per screen

Override the narrow hooks on `StateBase`, not `_onError`. The hierarchy
is intentional: routing is centralized; presentation is overridable.

| Override | When |
|---|---|
| `getErrorMsg(ErrorData)` | Custom message for a specific `error.type` / `statusCode`. Call `super` for defaults. |
| `onClientError(message, error)` | Replace the default dialog for 4xx with a snackbar/banner. |
| `showErrorDialog(message, error, {onClose})` | Switch every "show a dialog" path to a custom UI for this screen. |
| `backToAuth({onSuccess, onSkip})` | Override sign-in opening. App-level `StateBase` already wires `context.openSignIn()`. |
| `onCloseErrorDialog()` | Run additional cleanup when the user dismisses an error. Call `super` to clear `errorTypeShowing`. |
| `willHandleError` | Return `false` to opt the screen out of automatic registration entirely (rare; for screens with their own bespoke flow). |

Per-screen example:

```dart
class _FeatureScreenState extends StateBase<FeatureScreen> {
  @override
  String getErrorMsg(ErrorData error) {
    if (error.type == ErrorType.badResponse && error.statusCode == 422) {
      return trans.featureValidationError;
    }
    return super.getErrorMsg(error);
  }

  @override
  void onClientError(String? message, ErrorData error) {
    // 4xx → inline banner instead of the default dialog.
    _bannerController.show(message ?? trans.somethingWrong);
    onCloseErrorDialog();   // clear errorTypeShowing so dedupe doesn't lock us out
  }
}
```

## Dedup behaviour

`errorTypeShowing` is set when a dialog opens and cleared on close.
While set, identical-typed errors are suppressed. That's why a
custom handler must call `onCloseErrorDialog()` (or `super`) when its
banner/dialog dismisses — otherwise the user sees one error and then
nothing for follow-ups of the same type.

## Things that aren't routed

`ErrorData.fromObject` returns `null` for things that aren't `Exception`
or `Error` (e.g. you `throw 'string'` or `throw 42`). `CoreBlocBase`
falls through to `super.onError`, which just logs. If you genuinely
want a string error to surface, throw an `Exception('...')`.

`DioExceptionType.cancel` and `badCertificate` leave `ErrorData.type`
as `unknown` — in prod, those are silenced; in dev, you see the dialog.

## Checklist

- [ ] Bloc handlers throw / rethrow — no defensive `catch (_) {}`.
- [ ] Loading uses `showLoading()` / `hideLoading()` from inside the bloc (CoreDelegate fan-out), `try/finally` paired.
- [ ] No reimplementing `Failure` / `Result<T, F>` for cross-cutting use.
- [ ] When a screen overrides routing (e.g. `onClientError`), it calls `onCloseErrorDialog()` to clear the `errorTypeShowing` lock.
- [ ] When a screen needs a different message, it overrides `getErrorMsg` (and falls back to `super`), not `_onError`.
- [ ] App-level `backToAuth` is wired to the actual sign-in flow (it is, in `apps/main/lib/presentation/base/state_base/state_base.dart`).

## Common mistakes

- Wrapping every handler in `try { ... } catch (e) { /* ignore */ }` — the spinner sticks because nothing calls `hideLoading()`, and the user sees no error UI.
- Re-emitting an error state after `rethrow` in a bloc — handler logic continues against a possibly-closed bloc, and `_factories` may not have a matching state class.
- Calling the screen's `showLoading()` from a bloc — that's the wrong `showLoading`; use the delegate version (it's the one in scope inside `CoreBlocBase`).
- Forgetting to throw an `Exception` — a bare `throw 'oops'` is silently logged and doesn't show a dialog.
- Building a per-screen banner that never clears `errorTypeShowing`, so the second 4xx of the same kind is dropped.

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`data-layer`](../data-layer/SKILL.md)
- [`testing`](../testing/SKILL.md)
