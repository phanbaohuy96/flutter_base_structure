import 'package:fl_navigation/fl_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    if (dart.library.io) 'package:flutter_web_plugins/url_strategy.dart';

import 'browser_marker.dart' if (dart.library.html) 'browser_marker_web.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const NavigationDemoApp());
}

class NavigationDemoApp extends StatefulWidget {
  const NavigationDemoApp({super.key});

  @override
  State<NavigationDemoApp> createState() => _NavigationDemoAppState();
}

class _NavigationDemoAppState extends State<NavigationDemoApp> {
  late final GoRouter _router = buildFlGoRouter(
    routeProviders: [DemoRoute()],
    debugLogDiagnostics: true,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'fl_navigation example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      routerConfig: _router,
    );
  }
}

class DemoRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: DemoHomeScreen.routeName,
        name: DemoHomeScreen.routeName,
        builder: (_, __, ___) => const DemoHomeScreen(),
      ),
      CustomRouter<DemoArgs>(
        path: DemoDetailsScreen.routeName,
        name: DemoDetailsScreen.routeName,
        builder: (_, __, extra) {
          return DemoDetailsScreen(
            args: extra as DemoArgs? ?? DemoArgs.empty(),
          );
        },
        extraFromUrlQueries: DemoArgs.fromQuery,
      ),
      CustomRouter<DemoArgs>(
        path: DemoReplacementScreen.routeName,
        name: DemoReplacementScreen.routeName,
        builder: (_, __, extra) {
          return DemoReplacementScreen(
            args: extra as DemoArgs? ?? DemoArgs.empty(),
          );
        },
        extraFromUrlQueries: DemoArgs.fromQuery,
      ),
      CustomRouter<DemoArgs>(
        path: DemoResetScreen.routeName,
        name: DemoResetScreen.routeName,
        builder: (_, __, extra) {
          return DemoResetScreen(args: extra as DemoArgs? ?? DemoArgs.empty());
        },
        extraFromUrlQueries: DemoArgs.fromQuery,
      ),
    ];
  }
}

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'fl_navigation demo',
      routeName: routeName,
      markerMessage: 'home',
      children: [
        const Text('Home route'),
        FilledButton(
          key: const ValueKey('push-location-button'),
          onPressed: () {
            const PushNamedBehavior().push<void>(
              context,
              DemoDetailsScreen.routeName,
              arguments: const {'message': 'from location push'},
            );
          },
          child: const Text('Push with location'),
        ),
        FilledButton(
          key: const ValueKey('push-named-button'),
          onPressed: () {
            const PushNamedBehavior(
              goRouterNavigationTarget: GoRouterNavigationTarget.name,
            ).push<void>(
              context,
              DemoDetailsScreen.routeName,
              arguments: const {'message': 'from named push'},
            );
          },
          child: const Text('Push with named route'),
        ),
        FilledButton(
          key: const ValueKey('push-query-button'),
          onPressed: () {
            const PushNamedBehavior().push<void>(
              context,
              DemoDetailsScreen.routeName,
              arguments: const {'message': 'from query map'},
            );
          },
          child: const Text('Push with query map'),
        ),
        FilledButton(
          key: const ValueKey('replace-button'),
          onPressed: () {
            const PushReplacementNamedBehavior().push<void>(
              context,
              DemoReplacementScreen.routeName,
              arguments: const {'message': 'from replacement'},
            );
          },
          child: const Text('Replace current route'),
        ),
        FilledButton(
          key: const ValueKey('reset-button'),
          onPressed: () {
            PushNamedAndRemoveUntilBehavior.removeAll().push<void>(
              context,
              DemoResetScreen.routeName,
              arguments: const {'message': 'from reset'},
            );
          },
          child: const Text('Reset stack'),
        ),
      ],
    );
  }
}

class DemoDetailsScreen extends StatelessWidget {
  const DemoDetailsScreen({required this.args, super.key});

  static const routeName = '/details';

  final DemoArgs args;

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Details route',
      routeName: routeName,
      markerMessage: args.message,
      children: [
        Text(
          'Detail message: ${args.message}',
          key: const ValueKey('detail-message'),
        ),
        FilledButton(
          key: const ValueKey('back-button'),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          child: const Text('Back'),
        ),
      ],
    );
  }
}

class DemoReplacementScreen extends StatelessWidget {
  const DemoReplacementScreen({required this.args, super.key});

  static const routeName = '/replacement';

  final DemoArgs args;

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Replacement route',
      routeName: routeName,
      markerMessage: args.message,
      children: [
        Text(
          'Replacement message: ${args.message}',
          key: const ValueKey('replacement-message'),
        ),
      ],
    );
  }
}

class DemoResetScreen extends StatelessWidget {
  const DemoResetScreen({required this.args, super.key});

  static const routeName = '/reset';

  final DemoArgs args;

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Reset route',
      routeName: routeName,
      markerMessage: args.message,
      children: [
        Text(
          'Reset message: ${args.message}',
          key: const ValueKey('reset-message'),
        ),
        Text(
          'Can pop: ${context.canPop()}',
          key: const ValueKey('can-pop-label'),
        ),
      ],
    );
  }
}

class DemoArgs {
  const DemoArgs(this.message);

  factory DemoArgs.empty() => const DemoArgs('empty');

  factory DemoArgs.fromQuery(Map<String, dynamic> queryParameters) {
    return DemoArgs(queryParameters['message'] as String? ?? 'empty');
  }

  final String message;
}

class _DemoScaffold extends StatelessWidget {
  const _DemoScaffold({
    required this.title,
    required this.routeName,
    required this.markerMessage,
    required this.children,
  });

  final String title;
  final String routeName;
  final String markerMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBrowserMarker(
        route: routeName,
        message: markerMessage,
        canPop: context.canPop(),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
