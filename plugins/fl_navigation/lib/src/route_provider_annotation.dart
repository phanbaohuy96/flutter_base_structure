/// Marks an [IRoute] implementation for route-provider generation.
class FlRouteProvider {
  const FlRouteProvider({this.isRoot = false});

  /// Include this provider when another package scans this package.
  final bool isRoot;
}
