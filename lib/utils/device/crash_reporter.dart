import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../log/app_log_event.dart';

class CrashReporter {
  static void Function(FlutterErrorDetails details)?
      _previousFlutterErrorHandler;
  static ErrorCallback? _previousPlatformErrorHandler;

  /// 初始化全局异常上报
  /// 注意：远端上报仍受 Telemetry 隐私门禁控制。
  static void init() {
    _previousFlutterErrorHandler ??= FlutterError.onError;
    _previousPlatformErrorHandler ??= PlatformDispatcher.instance.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // Keep Flutter's default presentation and any existing handler, then add
      // our telemetry log. Crash reporting must not swallow framework errors.
      FlutterError.presentError(details);
      logEvent(
        message: "${details.exception}",
        logLevel: LogLevel.fatal,
        stackTrace: details.stack.toString(),
        params: {
          'source': 'flutter_error',
          'library': details.library,
        },
      );
      _previousFlutterErrorHandler?.call(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      // PlatformDispatcher catches async errors outside FlutterError. Returning
      // the previous handler result preserves the host app's existing policy.
      logEvent(
        message: "$error",
        logLevel: LogLevel.fatal,
        stackTrace: stack.toString(),
        params: {
          'source': 'platform_dispatcher',
        },
      );
      return _previousPlatformErrorHandler?.call(error, stack) ?? false;
    };
  }

  static void runGuarded(void Function() body) {
    // Host apps can wrap runApp with this helper to capture zone-level errors
    // without coupling their main() to Telemetry internals.
    runZonedGuarded(
      body,
      (Object error, StackTrace stack) {
        logEvent(
          message: "$error",
          logLevel: LogLevel.fatal,
          stackTrace: stack.toString(),
          params: {
            'source': 'zone',
          },
        );
      },
    );
  }
}
