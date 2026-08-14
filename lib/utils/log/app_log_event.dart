import 'package:flutter/material.dart';
import 'package:module_base/utils/telemetry/telemetry.dart';

enum LogLevel {
  info,
  warning,
  error,
  fatal,
  debug;

  String toLevel() {
    switch (this) {
      case LogLevel.info:
        return "info";
      case LogLevel.warning:
        return "warning";
      case LogLevel.error:
        return "error";
      case LogLevel.debug:
        return "debug";
      case LogLevel.fatal:
        return "fatal";
      default:
        return "info";
    }
  }
}

Future<void> logEvent({
  LogLevel logLevel = LogLevel.info,
  String? stackTrace,
  Map<String, dynamic>? params,
  required String message,
}) async {
  try {
    debugPrint("Telemetry logEvent： $message");
    await Telemetry.instance.log(
      level: logLevel.toLevel(),
      message: message,
      stackTrace: stackTrace,
      params: params,
    );
  } catch (e) {
    debugPrint("Telemetry logEvent error： $e");
    // 日志记录失败不应影响正常业务流程，不再向上抛出异常
  }
}
