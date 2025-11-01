
import 'dart:io';

import 'package:flutter/material.dart';

import '../device/device_info_helper.dart';
import '../device/device_utils.dart';
import '../log/app_log_event.dart';
import '../user/app_user_helper.dart';

class DotTracker {

  final String eventName;

  final String eventDescription;

  Map<String, dynamic>? eventProperties = null;

  DotTracker({
    required this.eventName,
    this.eventDescription = "",
    this.eventProperties
  });

  static DotTracker addBot(eventName, {description = "", Map<String, dynamic>? properties}) {
    return DotTracker(eventName: eventName, eventDescription: description, eventProperties: properties);
  }
  
  static DotTracker addDot(eventName, {description = "", Map<String, dynamic>? properties}) {
    return DotTracker(eventName: eventName, eventDescription: description, eventProperties: properties);
  }

  DotTracker addParam(String key, dynamic value) {
    eventProperties ??= {};
    eventProperties![key] = value;
    return this;
  }

  Future report() async {
    return reportDotEvent(
        eventName: eventName,
        eventDescription: eventDescription,
        eventProperties: eventProperties
    );
  }
}

Future<void> reportDotEvent({
  required String eventName,
  String eventDescription = "",
  Map<String, dynamic>? eventProperties,
}) async {
  debugPrint("Supabase 埋点上报： $eventName");

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

    var deviceType = "Phone";
    var isTablet = await DeviceUtils.isTabletDevice();
    if (isTablet) {
      deviceType = "Tablet";
    }

    await supabase
        .from('tracking_events')
        .insert({
      'event_name': eventName,
      'event_description': eventDescription,
      'event_properties': eventProperties,
      'platform': Platform.operatingSystem,
      'app_version': appInfo?['fullVersion'],
      'uuid': uuid,
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
    });
  } catch (e) {
    debugPrint("Supabase 埋点上报 错误： $e");
    rethrow;
  }

}
