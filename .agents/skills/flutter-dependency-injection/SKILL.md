---
name: flutter-dependency-injection
description: Teaches and applies Flutter/Dart dependency injection with Injectable + GetIt, grounded in this repo's Clean Architecture and code generation conventions. Use when changing DI wiring, adding BLoCs/use cases/repositories/modules, using @Named/@preResolve/@factoryParam/env registrations, reviewing DI best practices, or setting up DI tests.
license: MIT
metadata:
  audience: flutter-developers
  framework: flutter
  pattern: dependency-injection
---

# Flutter Dependency Injection

## Quick start

1. Read current repo guidance first: `AGENTS.md`, then `CONTEXT.md`/ADRs if they exist.
2. Confirm the stack: Injectable generates registrations; GetIt is the runtime container; `apps/main/lib/di/di.dart` is the app composition root.
3. Use GetIt only at composition boundaries: app startup, DI modules, routes/BlocProviders, integration tests, and explicit adapters. Inside business classes, use constructor injection.
4. Bind cross-layer abstractions with `@Injectable(as: Contract)`; consumers depend on contracts, not implementations.
5. After changing annotations, constructors, module providers, named values, pre-resolved values, or external package modules, run `make gen_main` for main-app changes or `make gen_all` for package/micro-package changes.

## Teaching model

- DI means object creation happens outside the object that uses the dependency.
- Constructor injection is the default because dependencies stay visible and testable.
- GetIt is the composition tool, not a permission slip for global state.
- Do not inject data already available as a method parameter, entity field, route extra, or widget prop.
- Use a module for third-party classes, static factories, `Future` setup, named URLs, or aliases.

## Repo patterns

- App startup calls `configureDependencies(env: Config.instance.appConfig.envName)` before app services are resolved.
- App DI lives in `apps/main/lib/di/di.dart`: generated `di.config.dart`, `GetIt get injector`, app modules, and external package modules.
- Micro packages use `@InjectableInit.microPackage()` and export generated `*.module.dart`; wire package modules from the app root when needed.
- Routes create BLoCs with `BlocProvider(create: (_) => injector())` or dispatch initial events at the route boundary.
- Generated files (`*.config.dart`, `*.g.dart`, `*.freezed.dart`) are never edited by hand.

## Implementation workflow

1. Identify the seam: BLoC, use case, repository, data source, plugin, storage, client, or config value.
2. Put the contract in the layer/package the caller may know.
3. Annotate implementations and inject through constructors:

```dart
abstract class AuthUsecase {
  Future<User> signIn(String phone, String password);
}

@Injectable(as: AuthUsecase)
class AuthUsecaseImpl implements AuthUsecase {
  AuthUsecaseImpl(this._repository);
  final AuthRepository _repository;
}

@Injectable()
class SignInBloc extends AppBlocBase<SignInEvent, SignInState> {
  SignInBloc(this._authUsecase)
      : super(SignInState.initial(data: _StateData.initial()));
  final AuthUsecase _authUsecase;
}
```

4. Resolve only at the route/composition boundary, e.g. `BlocProvider<SignInBloc>(create: (_) => injector(), child: const SignInScreen())`.
5. Use `@module` for external/factory values, e.g. named URLs, `Dio`, `SharedPreferences`, or aliases between app/core contracts.
6. Run generation only if generated inputs changed, then analyze/tests as appropriate.

## Review checklist

- No hidden service-locator calls inside BLoCs, use cases, repositories, entities, or business helpers.
- Locator access is limited to composition roots, routes/providers, DI modules, startup, or tests.
- Cross-layer callers depend on contracts; implementations live below the contract.
- Lifetimes match ownership: factory for stateless objects, `@lazySingleton` for shared stateful services, `@singleton`/`@preResolve` only when eager startup is intentional.
- `@Named` values have one clear source and matching parameter annotations.
- Runtime-only values use `@factoryParam`; stable configuration is registered normally.
- Environment-specific behavior uses Injectable env annotations or modules, not `if` chains in consumers.
- Tests instantiate classes directly with fakes when possible; container-based tests reset/override registrations explicitly.
- Generated DI files are updated by build_runner/make, not edited.

## Test setup guidance

- Unit tests: instantiate the class under test directly and pass fakes/mocks through the constructor.
- Widget/route tests: provide the BLoC or override the registration at the composition boundary.
- Integration tests using GetIt: reset between tests, register doubles before resolving, and avoid relying on test order.
- Prefer fakes that implement the contract over mocking GetIt itself.

## Helper script

Run from a repo root to find DI review signals:

```bash
python3 .agents/skills/flutter-dependency-injection/scripts/check_di_usage.py .
```

Use `--scope <path>` to narrow scans, `--include-baseline` to show known deferred warnings, and `--strict` to return non-zero when warnings are found. The checker skips generated files, allows likely composition boundaries, flags direct locator access elsewhere, and reminds you when DI annotations mean code generation may be needed.
