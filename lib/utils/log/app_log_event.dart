import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:module_base/utils/device/device_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../device/device_info_helper.dart';
import '../user/app_user_helper.dart';

final supabase = Supabase.instance.client;


Map<String, dynamic>? appInfo;

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

Connectivity requiresConnectivity() {
  final Connectivity connectivity = Connectivity();
  return connectivity;
}

DeviceInfoPlugin requiresDeviceInfo() {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  return deviceInfo;
}

Future<void> logEvent({
  LogLevel logLevel = LogLevel.info,
  String? stackTrace,
  required String message,
}) async {
  debugPrint("Supabase 记录日志： $message");

  try {
    var infoMap = await DeviceService.getDeviceInfo();
    String brand = infoMap['brand']?? "";
    String product = infoMap['product']?? "";
    String model = infoMap['model']?? "";
    String deviceName = infoMap['deviceName']?? "";

    String hardware = infoMap['hardware']?? "";
    String manufacturer = infoMap['manufacturer']?? "";
    String sdkInt = infoMap['version']['sdkInt'] ?? "";
    String baseOS = infoMap['version']['baseOS'] ?? "";

    String osVersion = infoMap['version']['osVersion'] ?? "";

    appInfo ??= await DeviceService.getAppInfo();

    var connectivityResult = await requiresConnectivity().checkConnectivity();
    var networkType = parserNetworkType(connectivityResult);

    final uuid = await AppUserHelper.getUUID();

    var deviceType = "Phone";
    var isTablet = await DeviceUtils.isTabletDevice();
    if (isTablet) {
      deviceType = "Tablet";
    }

    await supabase
        .from('zotpaper_logs')
        .insert({
      'level': logLevel.toLevel(),
      'message': message,
      'device_info': {
        'os': Platform.operatingSystem,
        'os_version': osVersion,
        'device_name': deviceName,
        'brand': brand,
        'model': model,
        'product': product,
        'hardware': hardware,
        'manufacturer': manufacturer,
        'sdkInt': sdkInt,
        'base_OS': baseOS,
        'device_type': deviceType,
      },
      // 'user_id': '', // 如果有的话
      'network_info': {
        'network_type': networkType,
      },
      'user_info': {
        'unique_id': uuid,
      },
      'app_info': {
        'app_name': appInfo?['appName'],
        'package_name': appInfo?['packageName'],
        'version_name': appInfo?['fullVersion'],
        'version_code': appInfo?['buildNumber'],
      },
      'stack_trace': stackTrace,
      'platform': Platform.operatingSystem,
      'additional_data': {
        'dart_version': Platform.version,
      },
    });
  } catch (e) {
    debugPrint("Supabase 错误： $e");
    rethrow;
  }

}

String parserNetworkType(ConnectivityResult connectivityResult) {
  switch (connectivityResult) {
    case ConnectivityResult.wifi:
      return 'wifi';
    case ConnectivityResult.mobile:
      return 'cellular';
    case ConnectivityResult.ethernet:
      return 'ethernet';
    case ConnectivityResult.vpn:
      return 'vpn';
    case ConnectivityResult.bluetooth:
      return 'bluetooth';
    case ConnectivityResult.other:
      return 'other';
    default:
      return 'offline';
  }
}