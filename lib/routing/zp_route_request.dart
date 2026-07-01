enum ZPRouteSource {
  /// Internal typed route request. External schema sources are deferred.
  internal,
  legacy,
}

class ZPRouteRequest {
  const ZPRouteRequest({
    required this.route,
    this.version = 1,
    this.routeSource = ZPRouteSource.internal,
    this.params = const <String, Object?>{},
    this.legacyRoute,
  });

  final String route;
  final int version;
  final ZPRouteSource routeSource;
  final Map<String, Object?> params;
  final String? legacyRoute;
}
