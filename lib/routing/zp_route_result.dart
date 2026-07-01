enum ZPFallbackType {
  login,
  limited,
  invalidParams,
  unknownRoute,
  safePage,
}

enum ZPRouteResultType {
  success,
  limited,
  invalidParams,
  loginRequired,
  unknownRoute,
  failed,
}

class ZPRouteResult {
  const ZPRouteResult({
    required this.type,
    required this.route,
    required this.reason,
  });

  const ZPRouteResult.success(String route)
      : this(type: ZPRouteResultType.success, route: route, reason: 'success');

  final ZPRouteResultType type;
  final String route;
  final String reason;

  bool get isSuccess => type == ZPRouteResultType.success;
}
