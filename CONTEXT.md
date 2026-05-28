# Flutter Base Structure

A Flutter project template for multi-flavor mobile apps. This document defines the architectural vocabulary used across the template — the names downstream apps inherit and should preserve.

## Language

### Module shape

**Module**:
A unit with an interface and an implementation — typically a feature directory under `presentation/modules/`, but the term also applies to a data-layer repository, a use case, or a plugin package.
_Avoid_: feature, component, service.

**Simple module**:
A module with one screen. Flat structure (`bloc/`, `views/`, `<module>_route.dart`, `<module>.dart` barrel). Does **not** get a coordinator file.
_Avoid_: single-page module.

**Compound module**:
A module with multiple screens. Each non-trivial screen is its own sub-module with its own BLoC, and the parent owns a coordinator.
_Avoid_: parent module, container module.

**Coordinator**:
A `BuildContext` extension that owns entry into a module's navigation: parameter translation (`*Args` construction), pre-nav guards (e.g., short-circuit when state allows), and post-nav handling. Compound modules and modules with non-trivial entry logic get one; bare one-line `pushBehavior.push` extensions do not.
_Avoid_: navigator, router extension.

### Route plumbing

**Route provider** (`IRoute`):
A class that contributes a list of `CustomRouter`s for a feature. Discovered via build-time annotation scanning; registered in the generated `route_providers.config.dart`.
_Avoid_: route module, route bundle.

**Route-provider interceptor** (`RouteProviderInterceptor`):
A runtime hook that observes or rewrites each `RouteProviderResolution` before it becomes a `GoRoute`. Calls one of `next` / `resolve` / `skip` / `reject` on the handler.
_Avoid_: route guard, router middleware.

**Auth-gate interceptor**:
The specific `RouteProviderInterceptor` adapter that protects routes by token presence. Wraps each protected router with a `redirect` callback that returns `/signin?redirect=…` when no token is in the storage seam. The canonical demonstration of the interceptor mechanism.
_Avoid_: auth guard, auth middleware.

**Sign-in redirect resolver** (`SignInRedirectResolver`):
The app-owned seam that decides where the sign-in flow lands a user once authenticated — the default home route, plus validation of a requested `?redirect=` target (rejecting off-site URLs and loop-backs to sign-in). The router redirect and the **Coordinator** both delegate to it, so the landing policy has one source of truth. The template binds `DefaultSignInRedirectResolver` (lands on the dev-mode dashboard demo); a downstream app rebinds this contract in its `AppModule` to set its own home route.
_Avoid_: home route constant, post-login navigator, redirect guard.

### Data layer

**Storage seam**:
The single module per scope that owns local persistence. `CoreLocalDataManager` is the core scope (theme, locale, token, cookie consent, launch state); `LocalDataManager` is the app scope (user info). They are deep modules — SharedPreferences and FlutterSecureStorage are private state, not public layers.
_Avoid_: preferences helper, data manager (when the helper/manager split is meant); local storage.

**Mock remote source**:
A data-layer adapter that satisfies a remote-source contract with in-memory fixtures, intended to be swapped for a real network adapter at the DI binding boundary. The template ships `MockAuthRemoteSource` as a worked example so downstream apps can replace just one binding to wire in a backend.
_Avoid_: fake api, stub repository.

### Generation surface

**Codegen template**:
The Dart string templates under `tools/module_generator/lib/res/templates/` that emit module scaffolding. Templates teach patterns — what they emit is what downstream developers copy.
_Avoid_: scaffolding, generator output (when referring to the template itself).

## Relationships

- A **Compound module** owns one **Coordinator**; a **Simple module** does not.
- A **Route provider** contributes one or more `CustomRouter`s; **Route-provider interceptors** observe each provider's resolution before it becomes a `GoRoute`.
- The **Auth-gate interceptor** reads token from the **Storage seam** and rewrites resolutions for protected providers; the **Sign-in redirect resolver** then decides where an authenticated user goes next (and where an already-authenticated user landing on `/signin` is sent).
- A **Coordinator** may call into the **Storage seam** for pre-nav guards (e.g., skip signin when token already present).
- A **Mock remote source** is bound at DI composition; the use case it backs treats it identically to a real adapter.
- **Codegen templates** emit module scaffolding consistent with the **Module shape** vocabulary — Simple modules get no coordinator file; Compound modules do.

## Example dialogue

> **Dev:** "Where should the token-presence check for the home route live — in the home **Coordinator** or somewhere in the route plumbing?"
> **Architect:** "Neither, directly. Put it in the **Auth-gate interceptor**. The interceptor inspects each **Route provider** and wraps the protected ones with a redirect. The home coordinator stays focused on home-specific entry logic, and the **Storage seam** is the only thing that knows where the token lives."

> **Dev:** "Should every new module the generator emits include a coordinator file?"
> **Architect:** "Only **Compound modules**. A **Simple module** with one screen and no entry-time logic just calls `pushBehavior.push(context, routeName)` directly. A one-line coordinator is shallow — it adds an indirection without leverage."

## Flagged ambiguities

- "data manager" and "preferences helper" were both used to mean the local-persistence layer. Resolved: the layer is the **Storage seam** (`CoreLocalDataManager` / `LocalDataManager`); raw SharedPreferences/SecureStorage access is private state inside it. The standalone `PreferencesHelper` class no longer exists as a public type.
- "auth guard" was used informally for both the **Auth-gate interceptor** and the **Coordinator**'s pre-nav check. Resolved: the interceptor protects routes at the plumbing level; the coordinator does feature-local checks (e.g., short-circuit signin when already authenticated). Both can coexist.
