import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef RouteVerifier = bool Function(
  Uri uri,
  dynamic extra,
);
typedef CoreRouteBuilder = Widget Function(
  BuildContext,
  Uri,
  dynamic extra,
);

typedef ExtraBuilder = dynamic Function(
  BuildContext,
  Uri,
  dynamic extra,
);

class CustomRouter {
  final String path;
  final RouteVerifier? verifier;
  final CoreRouteBuilder _builder;
  final ExtraBuilder? extraBuilder;

  const CustomRouter({
    required this.path,
    this.verifier,
    required CoreRouteBuilder builder,
    this.extraBuilder,
  }) : _builder = builder;

  bool canLaunch(Uri uri, dynamic extra) {
    if (verifier != null) {
      return verifier!.call(uri, extra);
    }

    return path == uri.path;
  }

  Widget build(BuildContext context, Uri uri, dynamic extra) {
    if (extraBuilder != null) {
      return _builder(
        context,
        uri,
        extraBuilder!(context, uri, extra),
      );
    }
    return _builder(context, uri, extra);
  }
}

abstract class IRoute {
  List<CustomRouter> routers();
}
