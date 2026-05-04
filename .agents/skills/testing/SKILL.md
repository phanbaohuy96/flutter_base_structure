---
name: testing
description: Writes unit and widget tests for blocs, repositories, and screens using bloc_test + mocktail
license: MIT
compatibility: all
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: testing
---

# Testing Skill

## When to use

- Adding coverage for a new bloc, repository, or screen.
- Locking down a fixed bug with a regression test.
- Verifying a state-machine path that's easy to break.

## Layout

Tests live next to the package they cover:

```
apps/main/test/                 # app-level tests
core/test/                      # core-level tests
modules/data_source/test/
plugins/<plugin>/test/
```

A common shape inside `apps/main/test/`:

```
test/
├── unit/
│   ├── bloc/
│   ├── domain/
│   └── data/
├── widget/
└── helpers/
```

## Running tests

```bash
flutter test                                  # current package
flutter test test/unit/bloc/foo_bloc_test.dart
make coverage_main                            # coverage on apps/main, via coverage.sh
```

Use project make targets when they exist; otherwise invoke `flutter test` and `flutter analyze` (or `dart analyze`) per package as needed. Do not assume every branch has aggregate analyze/test targets.

## Bloc tests

Use `bloc_test` for sequence assertions and `mocktail` for collaborators.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUsecase extends Mock implements FeatureUsecase {}

void main() {
  late _MockUsecase usecase;
  late FeatureBloc bloc;

  setUp(() {
    usecase = _MockUsecase();
    bloc = FeatureBloc(null, usecase);
  });

  tearDown(() => bloc.close());

  group('FeatureBloc', () {
    test('initial state is FeatureInitial with empty data', () {
      expect(bloc.state, isA<FeatureInitial>());
      expect(bloc.state.data.detail, isNull);
    });

    blocTest<FeatureBloc, FeatureState>(
      'GetFeatureEvent loads detail and stays in FeatureInitial',
      build: () {
        when(() => usecase.getById('1'))
            .thenAnswer((_) async => Item(id: '1', name: 'A'));
        return bloc;
      },
      act: (b) => b.add(GetFeatureEvent('1')),
      expect: () => [
        isA<FeatureInitial>().having((s) => s.detail?.id, 'detail.id', '1'),
      ],
    );
  });
}
```

Note: this template's blocs use `abstract class` state hierarchies, not freezed unions, so assert with `isA<FeatureInitial>()` plus `having(...)` rather than equality on a sealed union.

## Repository tests

```dart
class _MockApi extends Mock implements UserApiClient {}

void main() {
  late _MockApi api;
  late UserRepositoryImpl repo;

  setUp(() {
    api = _MockApi();
    repo = UserRepositoryImpl(api);
  });

  test('getUser delegates to api client', () async {
    final user = UserModel(id: '1', name: 'A');
    when(() => api.getUser('1')).thenAnswer((_) async => user);

    expect(await repo.getUser('1'), user);
    verify(() => api.getUser('1')).called(1);
  });
}
```

## Widget tests

Wrap the screen in the same providers it gets in production: a `BlocProvider` (with a mocked bloc) and `MaterialApp.router` or a plain `MaterialApp` with `Localizations` if your widget reads `context.l10n`.

```dart
class _MockBloc extends MockBloc<FeatureEvent, FeatureState>
    implements FeatureBloc {}

void main() {
  late _MockBloc bloc;

  setUp(() => bloc = _MockBloc());

  Widget pump(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<FeatureBloc>.value(value: bloc, child: child),
  );

  testWidgets('shows empty state when items is empty', (tester) async {
    when(() => bloc.state).thenReturn(
      FeatureInitial(data: const _StateData()),
    );
    await tester.pumpWidget(pump(const FeatureScreen()));
    expect(find.byType(EmptyData), findsOneWidget);
  });
}
```

For interactions, drive a real bloc through the actions extension instead of mocking — it catches more bugs.

## Mocktail conventions

- Always register `Fallback` values for any value-typed argument matchers (`registerFallbackValue(...)`).
- Prefer `verifyNever`/`verifyInOrder` over loose `verify`.
- Don't share `Mock` instances between tests — recreate in `setUp`.

## Checklist

- [ ] Test file mirrors the source path (`lib/.../foo_bloc.dart` ↔ `test/unit/bloc/foo_bloc_test.dart`).
- [ ] Bloc closed in `tearDown`.
- [ ] Each test exercises one behavior.
- [ ] Mocked dependencies use `mocktail` consistently across the file.
- [ ] Widget tests provide the same locale + theme + bloc context the screen needs.
- [ ] `flutter test` passes locally before commit.

## Common mistakes

- Asserting on `state == FeatureLoaded(...)` — equality is reference-based on these abstract state classes; use `isA<>().having(...)`.
- Forgetting `registerFallbackValue` for typed arguments and getting cryptic `mocktail` errors.
- Pumping a widget without a `MaterialApp` ancestor; localizations and themes blow up.

## Related

- [`bloc-pattern`](../bloc-pattern/SKILL.md)
- [`data-layer`](../data-layer/SKILL.md)
- [`error-handling`](../error-handling/SKILL.md)
