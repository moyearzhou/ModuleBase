import 'zp_route_param_spec.dart';
import 'zp_route_result.dart';

enum ZPLoginPolicy {
  none,
  loginOptional,
  loginRequired,
  zoteroOptional,
  zoteroRequired,
}

class ZPRouteSpec {
  const ZPRouteSpec({
    required this.route,
    required this.path,
    required this.loginPolicy,
    required this.fallbackType,
    this.params = const <String, ZPRouteParamSpec>{},
  });

  final String route;
  final String path;
  final ZPLoginPolicy loginPolicy;
  final ZPFallbackType fallbackType;
  final Map<String, ZPRouteParamSpec> params;

  List<String> get paramKeys => params.keys.toList(growable: false);

  ZPRouteValidationResult validate(Map<String, Object?> input) {
    final normalized = <String, Object?>{};

    for (final entry in params.entries) {
      final key = entry.key;
      final spec = entry.value;
      final hasValue = input.containsKey(key);
      final value = hasValue ? input[key] : spec.defaultValue;

      if (!spec.accepts(value)) {
        return ZPRouteValidationResult.invalid(
          route: route,
          reason: hasValue ? 'invalidParam' : 'missingRequiredParam',
          paramKey: key,
        );
      }

      if (hasValue || spec.defaultValue != null) {
        normalized[key] = value;
      }
    }

    return ZPRouteValidationResult.valid(
      route: route,
      params: normalized,
    );
  }
}

class ZPRouteValidationResult {
  const ZPRouteValidationResult._({
    required this.valid,
    required this.route,
    required this.reason,
    required this.params,
    this.paramKey,
  });

  const ZPRouteValidationResult.valid({
    required String route,
    required Map<String, Object?> params,
  }) : this._(
          valid: true,
          route: route,
          reason: 'success',
          params: params,
        );

  const ZPRouteValidationResult.invalid({
    required String route,
    required String reason,
    required String paramKey,
  }) : this._(
          valid: false,
          route: route,
          reason: reason,
          params: const <String, Object?>{},
          paramKey: paramKey,
        );

  final bool valid;
  final String route;
  final String reason;
  final Map<String, Object?> params;
  final String? paramKey;
}
