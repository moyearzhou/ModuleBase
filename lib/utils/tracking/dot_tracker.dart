import 'package:flutter/material.dart';
import 'package:module_base/utils/telemetry/telemetry.dart';

class DotTracker {
  final String eventName;

  final String eventDescription;

  Map<String, dynamic>? _eventProperties;

  DotTracker(
      {required this.eventName,
      this.eventDescription = "",
      Map<String, dynamic>? eventProperties})
      : _eventProperties = eventProperties;

  /// 创建埋点
  static DotTracker addDot(eventName,
      {description = "", Map<String, dynamic>? properties}) {
    return DotTracker(
        eventName: eventName,
        eventDescription: description,
        eventProperties: properties);
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
        eventProperties: _eventProperties);
  }
}

Future<void> reportDotEvent({
  required String eventName,
  String eventDescription = "",
  Map<String, dynamic>? eventProperties,
}) async {
  try {
    debugPrint("Telemetry trackEvent： $eventName");
    await Telemetry.instance.track(
      eventName: eventName,
      eventDescription: eventDescription,
      eventProperties: eventProperties,
    );
  } catch (e, stackTrace) {
    debugPrint("Telemetry track event failed： $e , stackTrace: $stackTrace");
    // 埋点上报失败不应影响正常业务流程，不再向上抛出异常
  }
}
