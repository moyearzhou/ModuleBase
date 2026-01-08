
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

  static Map<String, dynamic> _commonProperties = {};

  DotTracker({
    required this.eventName,
    this.eventDescription = "",
    this.eventProperties
  });

  static addCommonParam(String key, dynamic value) {
    _commonProperties[key] = value;
  }

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
    var infoMap = await DeviceService.getDeviceInfo();
    String brand = infoMap['brand']?? "";
    String product = infoMap['product']?? "";
    String model = infoMap['model']?? "";
    String deviceName = infoMap['deviceName']?? "";

    String hardware = infoMap['hardware']?? "";
    String manufacturer = infoMap['manufacturer']?? "";
    String sdkInt = infoMap['version']['sdkInt'].toString() ?? "";
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

    // 读取通用属性
    final commonProps = DotTracker._commonProperties;
    
    // 合并 user_info
    final userInfo = <String, dynamic>{
      'unique_id': uuid,
    };
    if (commonProps['user_info'] is Map) {
      userInfo.addAll(Map<String, dynamic>.from(commonProps['user_info']));
    }
    
    // 合并 device_info
    final deviceInfo = <String, dynamic>{
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
    };
    if (commonProps['device_info'] is Map) {
      deviceInfo.addAll(Map<String, dynamic>.from(commonProps['device_info']));
    }
    
    // 合并 event_properties
    final mergedEventProperties = <String, dynamic>{};
    if (eventProperties != null) {
      mergedEventProperties.addAll(eventProperties);
    }
    if (commonProps['event_properties'] is Map) {
      mergedEventProperties.addAll(Map<String, dynamic>.from(commonProps['event_properties']));
    }

    await supabase
        .from('tracking_events')
        .insert({
      'event_name': eventName,
      'event_description': eventDescription,
      'event_properties': mergedEventProperties.isNotEmpty ? mergedEventProperties : null,
      'platform': Platform.operatingSystem,
      'app_version': appInfo?['fullVersion'],
      'uuid': uuid,
      'device_info': deviceInfo,
      // 'user_id': '', // 如果有的话
      'network_info': {
        'network_type': networkType,
      },
      'user_info': userInfo,
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
