enum ZPRouteParamType {
  string,
  int,
  bool,
  stringList,
  object,
}

class ZPRouteParamSpec {
  const ZPRouteParamSpec({
    required this.type,
    this.required = false,
    this.defaultValue,
    this.allowedValues,
    this.sensitive = false,
  });

  final ZPRouteParamType type;
  final bool required;
  final Object? defaultValue;
  final Set<Object?>? allowedValues;

  /// Sensitive route params must only appear as keys in route logs.
  final bool sensitive;

  bool accepts(Object? value) {
    if (value == null) return !required;
    if (allowedValues != null && !allowedValues!.contains(value)) {
      return false;
    }

    return switch (type) {
      ZPRouteParamType.string => value is String,
      ZPRouteParamType.int => value is int,
      ZPRouteParamType.bool => value is bool,
      ZPRouteParamType.stringList => value is List<String> ||
          (value is List && value.every((item) => item is String)),
      ZPRouteParamType.object => true,
    };
  }
}
