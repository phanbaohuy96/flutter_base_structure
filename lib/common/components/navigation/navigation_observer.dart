import 'dart:async';

import 'package:flutter/material.dart';

final myNavigatorObserver = MyNavigatorObserver();

class MyNavigatorObserver extends NavigatorObserver {
  List<Route<dynamic>> routeStack = [];

  final _routeChangedController =
      StreamController<List<Route<dynamic>>>.broadcast();

  Stream<List<Route<dynamic>>> get onRouteChanged {
    return _routeChangedController.stream;
  }

  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    if (route != null) {
      routeStack.add(route);
      _routeChangedController.add(routeStack);
    }
  }

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
    _routeChangedController.add(routeStack);
  }

  @override
  void didRemove(Route? route, Route? previousRoute) {
    final last = routeStack.last;
    if (route?.settings.name == last.settings.name) {
      routeStack.removeLast();
      _routeChangedController.add(routeStack);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      routeStack
        ..removeLast()
        ..add(newRoute);
      _routeChangedController.add(routeStack);
    }
  }

  bool constaintRoute(String routeName) {
    return routeStack.any((e) => e.settings.name == routeName);
  }
}
