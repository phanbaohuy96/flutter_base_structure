---
name: bloc-pattern
description: Implements BLoC state management using AppBlocBase, an abstract State hierarchy, and a freezed _StateData
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: bloc
---

# BLoC Pattern Skill

## When to use

- Adding state management to a new module.
- Modifying events/states for an existing bloc.

## Conventions enforced

This template uses a specific bloc shape that is **not** the typical "freezed sealed union" pattern. The state hierarchy is hand-written `abstract class` siblings sharing a freezed `_StateData`; events are hand-written subclasses of an abstract event. Follow this shape exactly — `state.copyWith<T>()` and the `_factories` map depend on it.

1. Bloc extends `AppBlocBase<E, S>` (defined in `apps/main/lib/presentation/base/bloc_base.dart`, ultimately `CoreBlocBase` from `core/`).
2. Bloc is annotated `@Injectable()`. Use `@factoryParam` for runtime args.
3. Event classes inherit from a single abstract `<X>Event` — no freezed union.
4. State classes inherit from a single abstract `<X>State` and share a freezed `_StateData`. The base provides `copyWith<T extends <X>State>({_StateData? data})` backed by a `_factories` map.
5. `_StateData` is `@freezed sealed class _StateData with _$StateData` — generator declares it that way; do not change.
6. Imports: `package:core/core.dart` (re-exports flutter_bloc, AppBlocBase, helpers), `package:freezed_annotation/freezed_annotation.dart`, `package:injectable/injectable.dart`.
7. Run `make gen_all` after editing — `<feature>_bloc.freezed.dart` is generated.

## Reference: bloc file (`<feature>_bloc.dart`)

```dart
import 'dart:async';

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/usecases/<feature>/<feature>_usecase.dart';
import '../../../base/base.dart';

part '<feature>_bloc.freezed.dart';
part '<feature>_event.dart';
part '<feature>_state.dart';

@Injectable()
class FeatureBloc extends AppBlocBase<FeatureEvent, FeatureState> {
  final FeatureUsecase _usecase;

  FeatureBloc(
    @factoryParam Item? initial,
    this._usecase,
  ) : super(FeatureInitial(data: _StateData(initial: initial))) {
    on<GetFeatureEvent>(_onGet);
  }

  Future<void> _onGet(GetFeatureEvent event, Emitter<FeatureState> emit) async {
    final detail = await _usecase.getById(event.id);
    emit(state.copyWith<FeatureInitial>(
      data: state.data.copyWith(detail: detail),
    ));
  }
}
```

## Reference: state file (`<feature>_state.dart`)

```dart
// ignore_for_file: unused_element
part of '<feature>_bloc.dart';

@freezed
sealed class _StateData with _$StateData {
  const factory _StateData({
    Item? detail,
    @Default([]) List<Item> items,
    @Default(false) bool canLoadMore,
  }) = __StateData;
}

abstract class FeatureState {
  final _StateData data;

  FeatureState(this.data);

  T copyWith<T extends FeatureState>({_StateData? data}) {
    return _factories[T == FeatureState ? runtimeType : T]!(
      data ?? this.data,
    );
  }

  // Forward common reads off _StateData.
  Item? get detail => data.detail;
  List<Item> get items => data.items;
  bool get canLoadMore => data.canLoadMore;
}

class FeatureInitial extends FeatureState {
  FeatureInitial({required _StateData data}) : super(data);
}

class FeatureLoaded extends FeatureState {
  FeatureLoaded({required _StateData data}) : super(data);
}

final _factories = <Type, Function(_StateData data)>{
  FeatureInitial: (data) => FeatureInitial(data: data),
  FeatureLoaded: (data) => FeatureLoaded(data: data),
};
```

Add a new state class? Add it to `_factories` in the same edit — `copyWith<T>()` will throw at runtime otherwise.

## Reference: event file (`<feature>_event.dart`)

```dart
part of '<feature>_bloc.dart';

abstract class FeatureEvent {}

class GetFeatureEvent extends FeatureEvent {
  final String id;
  GetFeatureEvent(this.id);
}

class LoadMoreEvent extends FeatureEvent {}
```

For events that need to surface a result back to the caller (e.g. login flows), pass a `Completer<T>` on the event and complete it inside the handler. Choose `T` to carry the useful result object when the caller needs refreshed state; avoid returning only `bool` and forcing an immediate duplicate query.

## Loading + error handling

`StateBase<T>` (the screen base) wires `delegate?.addLoadingHandler` and `addErrorHandler` against the bloc's `CoreDelegate` mixin during `initState`. So a bloc generally does not call `showLoading`/`hideLoading` itself — the screen does, and `CoreBlocBase.onError` already routes thrown errors through the screen's error UI.

When you do need explicit control inside a handler:

```dart
Future<void> _onSubmit(SubmitEvent event, Emitter<FeatureState> emit) async {
  showLoading();   // CoreDelegate fan-out — wakes the screen's EasyLoading
  try {
    await _usecase.submit(event.payload);
    emit(state.copyWith<FeatureSuccess>());
  } finally {
    hideLoading();
  }
}
```

`showLoading()` / `hideLoading()` here are the `CoreDelegate` versions
inherited via `CoreBlocBase`. They notify every registered screen
(usually one) which then calls its own `showLoading()` / `hideLoading()`
on `EasyLoading`. There's a deliberate name collision with the screen's
methods — see `error-handling` for the full picture.

Throw or rethrow on errors — `CoreBlocBase.onError` converts them to `ErrorData` and forwards to the screen.

## Using state in the UI

`BlocBuilder` works against the runtime type:

```dart
BlocBuilder<FeatureBloc, FeatureState>(
  builder: (context, state) {
    if (state is FeatureLoaded) return _buildList(state.items);
    return _buildEmpty();
  },
)
```

Action files (see `extension-action`) typically use `_blocListener(BuildContext context, FeatureState state)` for side effects and dispatch events via `bloc.add(...)`.

## Checklist

- [ ] Bloc extends `AppBlocBase<E, S>` and is `@Injectable()`.
- [ ] `<feature>_bloc.dart` declares the three `part` directives (freezed, event, state).
- [ ] `_StateData` is `@freezed sealed class` and uses `@Default(...)` for non-nullable defaults.
- [ ] Every concrete state subclass has a matching entry in `_factories`.
- [ ] Events extend the abstract `<X>Event`; no freezed unions for events or states.
- [ ] Long-running handlers call `showLoading()` and pair it with `hideLoading()` in a `finally` block (CoreDelegate fan-out).
- [ ] `make gen_all` run after changes.

## Common mistakes

- Treating `FeatureState` as a freezed union (`FeatureState.loading()`/`.loaded()`) — this template does not.
- Forgetting to register a new concrete state in `_factories` (causes `Null check operator used on a null value` from `copyWith<T>`).
- Importing `package:flutter_bloc/flutter_bloc.dart` directly — go through `package:core/core.dart`.
- Doing both `emit(...error)` and `rethrow` — `CoreBlocBase.onError` already handles thrown errors; emit OR throw, don't double-fire.

## Related

- [`module-scaffold`](../module-scaffold/SKILL.md)
- [`extension-action`](../extension-action/SKILL.md)
- [`error-handling`](../error-handling/SKILL.md)
- [`data-layer`](../data-layer/SKILL.md)
