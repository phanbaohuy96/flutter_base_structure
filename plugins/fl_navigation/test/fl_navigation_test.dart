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

class _RouteArgs {
  const _RouteArgs(this.value);

  final String? value;
}
