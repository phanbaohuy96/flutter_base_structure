import 'package:flutter/material.dart';

final myNavigatorObserver = MyNavigatorObserver();

class MyNavigatorObserver extends NavigatorObserver {
  List<Route<dynamic>> routeStack = [];

  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    if (route != null) {
      routeStack.add(route);
    }
  }

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
  }

  @override
  void didRemove(Route? route, Route? previousRoute) {
    final last = routeStack.last;
    if (route?.settings.name == last.settings.name) {
      routeStack.removeLast();
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      routeStack
        ..removeLast()
        ..add(newRoute);
    }
  }

  bool constaintRoute(String routeName) {
    return routeStack.any((e) => e.settings.name == routeName);
  }
}
