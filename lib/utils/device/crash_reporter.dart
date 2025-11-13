import 'package:flutter/material.dart';

import '../log/app_log_event.dart';

class CrashReporter {

  /// 初始化全局异常上报
  /// 注意：使用该方法前必须先初始化Supabase
  static void init() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // 获取异常堆栈
      logEvent(message: "${details.exception}", logLevel: LogLevel.fatal, stackTrace: details.stack.toString());
      // 可以在这里上报异常
    };
  }
}