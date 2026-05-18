// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:core/presentation/route/core_route.dart' as route_provider_0;
import 'package:fl_navigation/fl_navigation.dart';

import '../modules/auth/authentication_route.dart' as route_provider_1;

class AppRouteProviders {
  const AppRouteProviders();

  IRoute get coreRoute => route_provider_0.CoreRoute();
  IRoute get authenticationRoute => route_provider_1.AuthenticationRoute();

  List<IRoute> get all {
    return [
      coreRoute,
      authenticationRoute,
    ];
  }
}

List<IRoute> buildAppRouteProviders() {
  return const AppRouteProviders().all;
}

