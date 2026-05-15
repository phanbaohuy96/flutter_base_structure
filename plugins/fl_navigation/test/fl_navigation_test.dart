import 'package:fl_navigation/fl_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';

void main() {
  group('buildFlGoRouter', () {
    test('enables URL reflection for imperative APIs by default', () {
      final previous = GoRouter.optionURLReflectsImperativeAPIs;
      addTearDown(() => GoRouter.optionURLReflectsImperativeAPIs = previous);
      GoRouter.optionURLReflectsImperativeAPIs = false;

      final router = buildFlGoRouter(routes: [_textRoute('/start', 'Start')]);
      addTearDown(router.dispose);

      expect(GoRouter.optionURLReflectsImperativeAPIs, isTrue);
    });

    test('allows URL reflection opt-out', () {
      final previous = GoRouter.optionURLReflectsImperativeAPIs;
      addTearDown(() => GoRouter.optionURLReflectsImperativeAPIs = previous);

      final router = buildFlGoRouter(
        routes: [_textRoute('/start', 'Start')],
        optionURLReflectsImperativeAPIs: false,
      );
      addTearDown(router.dispose);

      expect(GoRouter.optionURLReflectsImperativeAPIs, isFalse);
    });

    test('keeps generated providers unchanged without interceptors', () {
      final router = buildFlGoRouter(
        routeProviders: [
          _TestRouteProvider([_customTextRouter('/provider', 'Provider')]),
        ],
      );
      addTearDown(router.dispose);

      expect(_routePaths(router), contains('/provider'));
    });

    test('interceptor can skip a whole provider', () {
      final skippedProvider = _TestRouteProvider([
        _customTextRouter('/skipped', 'Skipped'),
      ]);
      final router = buildFlGoRouter(
        routeProviders: [
          _TestRouteProvider([_customTextRouter('/kept', 'Kept')]),
          skippedProvider,
        ],
        routeProviderInterceptors: [
          _TestRouteProviderInterceptor((resolution, handler) {
            if (identical(resolution.provider, skippedProvider)) {
              handler.skip();
              return;
            }
            handler.next(resolution);
          }),
        ],
      );
      addTearDown(router.dispose);

      expect(_routePaths(router), contains('/kept'));
      expect(_routePaths(router), isNot(contains('/skipped')));
    });

    test('interceptor can filter routers inside a provider', () {
      final provider = _TestRouteProvider([
        _customTextRouter('/signin', 'Sign in'),
        _customTextRouter('/register', 'Register'),
      ]);
      final router = buildFlGoRouter(
        routeProviders: [provider],
        routeProviderInterceptors: [
          _TestRouteProviderInterceptor((resolution, handler) {
            handler.next(
              resolution.copyWith(
                routers: resolution.routers
                    .where((router) => router.path != '/register')
                    .toList(),
              ),
            );
          }),
        ],
      );
      addTearDown(router.dispose);

      expect(_routePaths(router), contains('/signin'));
      expect(_routePaths(router), isNot(contains('/register')));
    });

    test('interceptors run in order', () {
      final observed = <String>[];
      final router = buildFlGoRouter(
        routeProviders: [
          _TestRouteProvider([
            _customTextRouter('/first', 'First'),
            _customTextRouter('/second', 'Second'),
          ]),
        ],
        routeProviderInterceptors: [
          _TestRouteProviderInterceptor((resolution, handler) {
            observed.add(_joinRoutePaths(resolution.routers));
            handler.next(
              resolution.copyWith(
                routers: resolution.routers
                    .where((router) => router.path != '/first')
                    .toList(),
              ),
            );
          }),
          _TestRouteProviderInterceptor((resolution, handler) {
            observed.add(_joinRoutePaths(resolution.routers));
            handler.next(resolution);
          }),
        ],
      );
      addTearDown(router.dispose);

      expect(observed, ['/first,/second', '/second']);
      expect(_routePaths(router), ['/second']);
    });

    test('resolve stops the interceptor chain', () {
      final router = buildFlGoRouter(
        routeProviders: [
          _TestRouteProvider([_customTextRouter('/original', 'Original')]),
        ],
        routeProviderInterceptors: [
          _TestRouteProviderInterceptor((resolution, handler) {
            handler.resolve(
              resolution.copyWith(
                routers: [_customTextRouter('/resolved', 'Resolved')],
              ),
            );
          }),
          _TestRouteProviderInterceptor((_, __) {
            fail('Resolved route providers must stop the chain.');
          }),
        ],
      );
      addTearDown(router.dispose);

      expect(_routePaths(router), ['/resolved']);
    });

    test('reject surfaces an error', () {
      final error = StateError('blocked');

      expect(
        () => buildFlGoRouter(
          routeProviders: [
            _TestRouteProvider([_customTextRouter('/blocked', 'Blocked')]),
          ],
          routeProviderInterceptors: [
            _TestRouteProviderInterceptor((_, handler) {
              handler.reject(error);
            }),
          ],
        ),
        throwsA(same(error)),
      );
    });

    test('standalone routers and raw routes are not intercepted', () {
      final router = buildFlGoRouter(
        routeProviders: [
          _TestRouteProvider([_customTextRouter('/provider', 'Provider')]),
        ],
        routeProviderInterceptors: [
          _TestRouteProviderInterceptor((_, handler) => handler.skip()),
        ],
        routers: [_customTextRouter('/standalone', 'Standalone')],
        routes: [_textRoute('/raw', 'Raw')],
      );
      addTearDown(router.dispose);

      expect(_routePaths(router), isNot(contains('/provider')));
      expect(_routePaths(router), contains('/standalone'));
      expect(_routePaths(router), contains('/raw'));
    });
  });

  group('CustomRouter', () {
    test('builds extra from direct value, map extra, and query params', () {
      final router = CustomRouter<_RouteArgs>(
        path: '/sample',
        builder: (_, __, ___) => const SizedBox(),
        extraFromUrlQueries: (queryParameters) {
          return _RouteArgs(queryParameters['value'] as String?);
        },
      );
      const directArgs = _RouteArgs('direct');

      expect(
        router.buildExtra(Uri(path: '/sample'), directArgs),
        same(directArgs),
      );
      expect(
        router.buildExtra(Uri(path: '/sample'), {'value': 'map'}),
        isA<_RouteArgs>().having((args) => args.value, 'value', 'map'),
      );
      expect(
        router.buildExtra(Uri.parse('/sample?value=query'), null),
        isA<_RouteArgs>().having((args) => args.value, 'value', 'query'),
      );
    });

    test('converts route metadata to GoRoute', () {
      final navigatorKey = GlobalKey<NavigatorState>();
      final router = CustomRouter(
        path: '/parent',
        name: 'parent',
        parentNavigatorKey: navigatorKey,
        builder: (_, __, ___) => const SizedBox(),
        pageBuilder: (_, __, ___) {
          return const MaterialPage<void>(child: Text('Parent'));
        },
        redirect: (_, __) => null,
        routes: [
          CustomRouter(
            path: 'child',
            builder: (_, __, ___) => const SizedBox(),
          ),
        ],
      );

      final goRoute = router.toGoRoute();

      expect(goRoute.path, '/parent');
      expect(goRoute.name, 'parent');
      expect(goRoute.parentNavigatorKey, same(navigatorKey));
      expect(goRoute.pageBuilder, isNotNull);
      expect(goRoute.builder, isNull);
      expect(goRoute.redirect, isNotNull);
      expect(goRoute.routes, hasLength(1));
    });

    test('copyWith preserves metadata and replaces nested routes', () {
      final navigatorKey = GlobalKey<NavigatorState>();
      final router = CustomRouter(
        path: '/parent',
        name: 'parent',
        parentNavigatorKey: navigatorKey,
        builder: (_, __, ___) => const SizedBox(),
        routes: [
          CustomRouter(
            path: 'first',
            builder: (_, __, ___) => const SizedBox(),
          ),
          CustomRouter(
            path: 'second',
            builder: (_, __, ___) => const SizedBox(),
          ),
        ],
      );

      final updated = router.copyWith(
        path: '/updated',
        routes: [router.routes!.last],
      );
      final goRoute = updated.toGoRoute();

      expect(goRoute.path, '/updated');
      expect(goRoute.name, 'parent');
      expect(goRoute.parentNavigatorKey, same(navigatorKey));
      expect(goRoute.routes, hasLength(1));
      expect((goRoute.routes.single as GoRoute).path, 'second');
    });
  });

  group('PushBehavior', () {
    test('builds a location from route name', () {
      final uri = const PushNamedBehavior().buildUri('/signin', null);

      expect(uri.toString(), '/signin');
    });

    testWidgets('named push uses GoRouter named routes when requested', (
      tester,
    ) async {
      late BuildContext currentContext;
      final router = _buildTextRouter(
        routes: const {'/start': 'Start', '/target': 'Target'},
        onBuild: (context) => currentContext = context,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      unawaited(
        const PushNamedBehavior(
          goRouterNavigationTarget: GoRouterNavigationTarget.name,
        ).push<Object?>(
          currentContext,
          '/target',
          arguments: const {'message': 'target'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Target'), findsOneWidget);
    });

    testWidgets('pushReplacement uses location paths by default', (
      tester,
    ) async {
      late BuildContext currentContext;
      final router = _buildTextRouter(
        routes: const {'/start': 'Start', '/target': 'Target'},
        onBuild: (context) => currentContext = context,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      unawaited(
        const PushReplacementNamedBehavior().push<Object?>(
          currentContext,
          '/target',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Target'), findsOneWidget);
    });

    testWidgets('removeAll uses go semantics with GoRouter', (tester) async {
      late BuildContext currentContext;
      final router = _buildTextRouter(
        routes: const {
          '/start': 'Start',
          '/middle': 'Middle',
          '/target': 'Target',
        },
        onBuild: (context) => currentContext = context,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      unawaited(
        const PushNamedBehavior().push<Object?>(currentContext, '/middle'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Middle'), findsOneWidget);
      expect(router.canPop(), isTrue);

      await PushNamedAndRemoveUntilBehavior.removeAll().push<Object?>(
        currentContext,
        '/target',
      );
      await tester.pumpAndSettle();

      expect(find.text('Target'), findsOneWidget);
      expect(router.canPop(), isFalse);
    });
  });
}

GoRouter _buildTextRouter({
  required Map<String, String> routes,
  required ValueSetter<BuildContext> onBuild,
}) {
  return GoRouter(
    initialLocation: '/start',
    routes: routes.entries.map((entry) {
      return GoRoute(
        path: entry.key,
        name: entry.key,
        builder: (context, _) {
          onBuild(context);
          return Material(child: Text(entry.value));
        },
      );
    }).toList(),
  );
}

GoRoute _textRoute(String path, String text) {
  return GoRoute(
    path: path,
    builder: (_, _) => Material(child: Text(text)),
  );
}

CustomRouter _customTextRouter(String path, String text) {
  return CustomRouter(
    path: path,
    builder: (_, __, ___) => Material(child: Text(text)),
  );
}

List<String> _routePaths(GoRouter router) {
  return router.configuration.routes
      .whereType<GoRoute>()
      .map((route) => route.path)
      .toList();
}

String _joinRoutePaths(List<CustomRouter> routers) {
  return routers.map((router) => router.path).join(',');
}

class _TestRouteProvider extends IRoute {
  _TestRouteProvider(this._routers);

  final List<CustomRouter> _routers;

  @override
  List<CustomRouter> routers() {
    return _routers;
  }
}

class _TestRouteProviderInterceptor extends RouteProviderInterceptor {
  const _TestRouteProviderInterceptor(this._onResolve);

  final void Function(RouteProviderResolution, RouteProviderInterceptorHandler)
  _onResolve;

  @override
  void onResolve(
    RouteProviderResolution resolution,
    RouteProviderInterceptorHandler handler,
  ) {
    _onResolve(resolution, handler);
  }
}

class _RouteArgs {
  const _RouteArgs(this.value);

  final String? value;
}
