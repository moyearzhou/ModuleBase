// ignore_for_file: avoid_print

/// See: https://github.com/flutter/flutter/issues/11392
enum BuildMode {
  release,
  debug,
  profile,
  ;

  static final isDebug = _buildMode == BuildMode.debug;
  static final isProfile = _buildMode == BuildMode.profile;
  static final isRelease = _buildMode == BuildMode.release;
}

final _buildMode = () {
  if (const bool.fromEnvironment('dart.vm.product')) {
    return BuildMode.release;
  }
  var result = BuildMode.profile;
  assert(() {
    result = BuildMode.debug;
    return true;
  }());
  return result;
}();

/// Print [msg] only in debug mode.
/// [msg] will convert to string by default.
/// Print [msg]s only in debug mode.
/// [msg] will convert to string by default.
void dprint(Object? msg, [Object? msg2, Object? msg3, Object? msg4]) {
  if (!BuildMode.isDebug) return;
  print(msg);
  if (msg2 != null) {
    print('\t');
    print(msg2);
  }
  if (msg3 != null) {
    print('\t');
    print(msg3);
  }
  if (msg4 != null) {
    print('\t');
    print(msg4);
  }
}
