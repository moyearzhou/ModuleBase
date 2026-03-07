import 'dart:io';
import 'package:flutter/material.dart';
import 'package:module_base/global/global_params.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../user/app_user_helper.dart';

const String APP_INFO = "app_info";

class DotTracker {

  final String eventName;

  final String eventDescription;

  Map<String, dynamic>? _eventProperties = null;

  DotTracker({
    required this.eventName,
    this.eventDescription = "",
    Map<String, dynamic>? eventProperties
  }):  _eventProperties = eventProperties;

  /// 创建埋点
  static DotTracker addDot(eventName, {description = "", Map<String, dynamic>? properties}) {
    return DotTracker(eventName: eventName, eventDescription: description, eventProperties: properties);
  }

  /// 添加埋点参数
  DotTracker addParam(String key, dynamic value) {
    _eventProperties ??= {};
    _eventProperties![key] = value;
    return this;
  }

  /// 上报埋点
  Future<void> report() async {
    return reportDotEvent(
        eventName: eventName,
        eventDescription: eventDescription,
        eventProperties: _eventProperties
    );
  }
}

Future<void> reportDotEvent({
  required String eventName,
  String eventDescription = "",
  Map<String, dynamic>? eventProperties,
}) async {
  debugPrint("Supabase trackEvent： $eventName");

  try {
    final uuid = await AppUserHelper.getUUID();

    // 通用属性
    final commonProps = GlobalReportParams.getCommonParams();
    
    // 用户信息
    final userInfo = await GlobalReportParams.getUserInfoMap();
    
    // 合并 device_info
    final deviceInfo = await GlobalReportParams.getDeviceInfoMap();

    // app信息
    final appInfoMap = await GlobalReportParams.getAppInfoMap();

    // 网络信息
    final netWorkInfoMap = await GlobalReportParams.getNetWorkInfoMap();

    // 合并 event_properties
    final mergedEventProperties = <String, dynamic>{};
    if (eventProperties != null) {
      mergedEventProperties.addAll(eventProperties);
    }
    if (commonProps['event_properties'] is Map) {
      mergedEventProperties.addAll(Map<String, dynamic>.from(commonProps['event_properties']));
    }

    await Supabase.instance.client
        .from('tracking_events')
        .insert({
      'event_name': eventName,
      'event_description': eventDescription,
      'event_properties': mergedEventProperties.isNotEmpty ? mergedEventProperties : null,
      'platform': Platform.operatingSystem,
      'app_version': appInfoMap['version_name'],
      'uuid': uuid,
      'device_info': deviceInfo,
      // 'user_id': '', // 如果有的话
      'network_info': netWorkInfoMap,
      'user_info': userInfo,
      'app_info': appInfoMap,
    });
  } catch (e, stackTrace) {
    debugPrint("Supabase track event failed： $e , stackTrace: $stackTrace");
    // 埋点上报失败不应影响正常业务流程，不再向上抛出异常
  }
}
