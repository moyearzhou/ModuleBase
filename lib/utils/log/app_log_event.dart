import 'dart:io';
import 'package:flutter/material.dart';
import 'package:module_base/global/global_params.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  debugPrint("Supabase logEvent： $message");

  try {
    // 用户信息
    final userInfo = await GlobalReportParams.getUserInfoMap();

    // 合并 device_info
    final deviceInfo = await GlobalReportParams.getDeviceInfoMap();

    // app信息
    final appInfoMap = await GlobalReportParams.getAppInfoMap();

    // 网络信息
    final netWorkInfoMap = await GlobalReportParams.getNetWorkInfoMap();

    var additionalData = params ?? {};

    await Supabase.instance.client
        .from('zotpaper_logs')
        .insert({
      'level': logLevel.toLevel(),
      'message': message,
      'device_info': deviceInfo,
      // 'user_id': '', // 如果有的话
      'network_info': netWorkInfoMap,
      'user_info': userInfo,
      'app_info': appInfoMap,
      'stack_trace': stackTrace,
      'platform': Platform.operatingSystem,
      'additional_data': additionalData,
    });
  } catch (e) {
    debugPrint("Supabase logEvent error： $e");
    // 日志记录失败不应影响正常业务流程，不再向上抛出异常
  }

}