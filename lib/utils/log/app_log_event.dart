import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../device/device_info_helper.dart';
import '../user/app_user_helper.dart';

final supabase = Supabase.instance.client;

final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

final Connectivity connectivity = Connectivity();

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

Future<void> logEvent({
  LogLevel logLevel = LogLevel.info,
  String? stackTrace,
  required String message,
}) async {
  debugPrint("Supabase 记录日志： $message");

  try {
    var info = await deviceInfo.androidInfo;
    String brand = info.brand;
    String product = info.product;
    String model = info.model;
    String deviceName = info.name;

    String hardware = info.hardware;
    String manufacturer = info.manufacturer;
    String sdkInt = info.version.sdkInt.toString();
    String baseOS = info.version.baseOS.toString();

    String osVersion = info.version.release.toString();

    appInfo ??= await DeviceService.getAppInfo();

    var connectivityResult = await connectivity.checkConnectivity();
    var networkType = parserNetworkType(connectivityResult);

    final uuid = await AppUserHelper.getUUID();

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