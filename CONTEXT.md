# Flutter Base Structure

A Flutter project template for multi-flavor mobile apps. This document defines the architectural vocabulary used across the template — the names downstream apps inherit and should preserve.

## Language

### Module shape

**Module**:
A unit with an interface and an implementation — typically a feature directory under `presentation/modules/`, but the term also applies to a data-layer repository, a use case, or a plugin package.
_Avoid_: feature, component, service.

**Simple module**:
A module with one screen. Flat structure (`bloc/`, `views/`, `<module>_route.dart`, `<module>_coordinator.dart`, `<module>.dart` barrel).
_Avoid_: single-page module.

**Compound module**:
A module with multiple screens. Each non-trivial screen is its own sub-module with its own BLoC, and the parent owns a coordinator.
_Avoid_: parent module, container module.

**Coordinator**:
A `BuildContext` extension that owns entry into a module's navigation: parameter translation (`*Args` construction), pre-nav guards (e.g., short-circuit when state allows), and post-nav handling. Every module gets one, so there is exactly one place a caller enters a module from and route paths never leak into feature code. What a coordinator owns varies: modules with route arguments translate them; argument-free modules hold the entry-guard seam. A coordinator that never grows past a bare `pushBehavior.push` forward is dead weight — delete it and call the screen's `routeName` directly.
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
The app-owned seam that decides where the sign-in flow lands a user once authenticated. It is a template-method base: it exposes one overridable knob — `home`, the default landing route — and owns the `resolve` validation of a requested `?redirect=` target (rejecting off-site URLs and loop-backs to sign-in) as inherited, shared behaviour. The router redirect and the **Coordinator** both delegate to it, so the landing policy has one source of truth and the open-redirect protection cannot be dropped by accident. The template binds `DefaultSignInRedirectResolver` (lands on the dev-mode dashboard demo); a downstream app extends the base and overrides `home` to set its own landing route (inheriting the validation), and may override `resolve` for a different policy.
_Avoid_: home route constant, post-login navigator, redirect guard.

### Data layer

**Storage seam**:
The single module per scope that owns local persistence. `CoreLocalDataManager` is the core scope (theme, locale, token, cookie consent, launch state); `LocalDataManager` is the app scope (user info). They are deep modules — SharedPreferences and FlutterSecureStorage are private state, not public layers.
_Avoid_: preferences helper, data manager (when the helper/manager split is meant); local storage.

**Repository**:
A retrofit client — a `@RestApi()` abstract class whose annotated methods are the endpoints, with the implementation generated into its `.g.dart` part and bound through an injectable `@module` provider. There is no separate contract-plus-impl pair: retrofit writes the implementation, so an interface beside it would hold nothing. The abstraction that keeps transport out of `domain/` is the **Use case** above it.
_Avoid_: api client, data source, service (for the same thing); repository interface.

**Repository transport**:
Which wire protocol a repository speaks — REST, where one annotated method is one endpoint, or GraphQL, where every operation posts to one endpoint and a hand-written class above the client composes the document and reads the `errors` array. The module generator asks which one to scaffold (`--transport rest|graphql`), emits one worked endpoint rather than a CRUD set, scaffolds the payload model the endpoint returns, and only writes into a package that declares `retrofit`, `dio` and `core` as runtime dependencies.
_Avoid_: api layer, client (when the transport choice is meant).

**Remote-source port**:
A contract declared in `domain/` for data the app fetches from somewhere it does not own, with the adapter that satisfies it bound at DI composition. The adapter may be a network client or in-memory fixtures; swapping one for the other is a change to the binding and to nothing above it. The template ships a fixture adapter for the sign-in flow as a worked example — demo content a real app deletes.
_Avoid_: fake api, stub repository, mock remote source (for the contract itself — the mock is one adapter, not the seam).

### Generation surface

**Codegen template**:
The Dart string templates under `tools/module_generator/lib/res/templates/` that emit module scaffolding. Templates teach patterns — what they emit is what downstream developers copy.
_Avoid_: scaffolding, generator output (when referring to the template itself).

## Relationships

- Every module owns one **Coordinator**; a **Compound module**'s lives on the parent, alongside the parent barrel and route aggregator.
- A **Route provider** contributes one or more `CustomRouter`s; **Route-provider interceptors** observe each provider's resolution before it becomes a `GoRoute`.
- The **Auth-gate interceptor** reads token from the **Storage seam** and rewrites resolutions for protected providers; the **Sign-in redirect resolver** then decides where an authenticated user goes next (and where an already-authenticated user landing on `/signin` is sent).
- A **Coordinator** may call into the **Storage seam** for pre-nav guards (e.g., skip signin when token already present).
- A **Remote-source port** is satisfied by exactly one adapter per environment, bound at DI composition; the use case it backs treats a fixture adapter and a network adapter identically.
- A **Repository** is named by the use case above it, never by a bloc directly; swapping its **Repository transport**, or standing a **Remote-source port** in for it, is a change to that use case's constructor and nothing else.
- **Codegen templates** emit module scaffolding consistent with the **Module shape** vocabulary — every generated module ships a **Coordinator**, and the ones with route arguments wire `*Args` translation into it.

## Example dialogue

> **Dev:** "Where should the token-presence check for the home route live — in the home **Coordinator** or somewhere in the route plumbing?"
> **Architect:** "Neither, directly. Put it in the **Auth-gate interceptor**. The interceptor inspects each **Route provider** and wraps the protected ones with a redirect. The home coordinator stays focused on home-specific entry logic, and the **Storage seam** is the only thing that knows where the token lives."

> **Dev:** "Should every new module the generator emits include a coordinator file?"
> **Architect:** "Yes — the generator can't know which modules will grow entry logic, and retrofitting a **Coordinator** later means chasing every `pushBehavior.push` call site that already hard-coded a route path. Scaffolding one up front costs a file and buys a single entry point. The rule that still holds is the *shape*: a coordinator has to own something. Where the module takes route arguments the generator wires `*Args` translation in, so it earns its place immediately. Where it doesn't, the generated method is a guard seam with a `TODO(template)` telling you to delete the file if entry logic never arrives — a permanent bare forwarder is still indirection without leverage."

## Flagged ambiguities

- "data manager" and "preferences helper" were both used to mean the local-persistence layer. Resolved: the layer is the **Storage seam** (`CoreLocalDataManager` / `LocalDataManager`); raw SharedPreferences/SecureStorage access is private state inside it. The standalone `PreferencesHelper` class no longer exists as a public type.
- "auth guard" was used informally for both the **Auth-gate interceptor** and the **Coordinator**'s pre-nav check. Resolved: the interceptor protects routes at the plumbing level; the coordinator does feature-local checks (e.g., short-circuit signin when already authenticated). Both can coexist.
- "mock remote source" named the seam after the one adapter the template happens to ship, so guidance written against it read as advice about a fixture and went stale when the fixture did. Resolved: the seam is the **Remote-source port**; a mock is one adapter satisfying it, and adapters implement the port rather than each other.
