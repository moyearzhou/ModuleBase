enum TelemetryRecordType {
  event,
  log,
}

enum TelemetryPriority {
  critical,
  normal,
  low,
}

class TelemetryRecord {
  final String id;
  final TelemetryRecordType type;
  final String? eventName;
  final String? eventDescription;
  final Map<String, dynamic>? eventProperties;
  final String? message;
  final String? level;
  final String? stackTrace;
  final Map<String, dynamic>? additionalData;
  final Map<String, dynamic>? networkInfo;
  final Map<String, dynamic>? deviceInfo;
  final Map<String, dynamic>? appInfo;
  final Map<String, dynamic>? userInfo;
  final String? platform;
  final String? appVersion;
  final DateTime loggedAt;
  final TelemetryPriority priority;
  final int attemptCount;
  final DateTime? nextRetryAt;
  final DateTime createdLocalAt;

  const TelemetryRecord({
    required this.id,
    required this.type,
    required this.loggedAt,
    required this.createdLocalAt,
    this.eventName,
    this.eventDescription,
    this.eventProperties,
    this.message,
    this.level,
    this.stackTrace,
    this.additionalData,
    this.networkInfo,
    this.deviceInfo,
    this.appInfo,
    this.userInfo,
    this.platform,
    this.appVersion,
    this.priority = TelemetryPriority.normal,
    this.attemptCount = 0,
    this.nextRetryAt,
  });

  TelemetryRecord copyWith({
    String? eventDescription,
    Map<String, dynamic>? eventProperties,
    String? message,
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? networkInfo,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? appInfo,
    Map<String, dynamic>? userInfo,
    String? platform,
    String? appVersion,
    String? stackTrace,
    int? attemptCount,
    DateTime? nextRetryAt,
  }) {
    return TelemetryRecord(
      id: id,
      type: type,
      loggedAt: loggedAt,
      createdLocalAt: createdLocalAt,
      eventName: eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventProperties: eventProperties ?? this.eventProperties,
      message: message ?? this.message,
      level: level,
      stackTrace: stackTrace ?? this.stackTrace,
      additionalData: additionalData ?? this.additionalData,
      networkInfo: networkInfo ?? this.networkInfo,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appInfo: appInfo ?? this.appInfo,
      userInfo: userInfo ?? this.userInfo,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      priority: priority,
      attemptCount: attemptCount ?? this.attemptCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  Map<String, dynamic> toQueueJson() {
    return {
      'id': id,
      'type': type.name,
      'event_name': eventName,
      'event_description': eventDescription,
      'event_properties': eventProperties,
      'message': message,
      'level': level,
      'stack_trace': stackTrace,
      'additional_data': additionalData,
      'network_info': networkInfo,
      'device_info': deviceInfo,
      'app_info': appInfo,
      'user_info': userInfo,
      'platform': platform,
      'app_version': appVersion,
      'logged_at': loggedAt.toUtc().toIso8601String(),
      'priority': priority.name,
      'attempt_count': attemptCount,
      'next_retry_at': nextRetryAt?.toUtc().toIso8601String(),
      'created_local_at': createdLocalAt.toUtc().toIso8601String(),
    };
  }

  static TelemetryRecord fromQueueJson(Map<String, dynamic> json) {
    return TelemetryRecord(
      id: json['id']?.toString() ?? '',
      type: _recordTypeFrom(json['type']),
      eventName: json['event_name']?.toString(),
      eventDescription: json['event_description']?.toString(),
      eventProperties: _mapFrom(json['event_properties']),
      message: json['message']?.toString(),
      level: json['level']?.toString(),
      stackTrace: json['stack_trace']?.toString(),
      additionalData: _mapFrom(json['additional_data']),
      networkInfo: _mapFrom(json['network_info']),
      deviceInfo: _mapFrom(json['device_info']),
      appInfo: _mapFrom(json['app_info']),
      userInfo: _mapFrom(json['user_info']),
      platform: json['platform']?.toString(),
      appVersion: json['app_version']?.toString(),
      loggedAt: _dateFrom(json['logged_at']),
      priority: _priorityFrom(json['priority']),
      attemptCount: int.tryParse(json['attempt_count']?.toString() ?? '') ?? 0,
      nextRetryAt: json['next_retry_at'] == null
          ? null
          : _dateFrom(json['next_retry_at']),
      createdLocalAt: _dateFrom(json['created_local_at']),
    );
  }

  static TelemetryRecordType _recordTypeFrom(dynamic value) {
    return TelemetryRecordType.values.firstWhere(
      (type) => type.name == value?.toString(),
      orElse: () => TelemetryRecordType.event,
    );
  }

  static TelemetryPriority _priorityFrom(dynamic value) {
    return TelemetryPriority.values.firstWhere(
      (priority) => priority.name == value?.toString(),
      orElse: () => TelemetryPriority.normal,
    );
  }

  static DateTime _dateFrom(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static Map<String, dynamic>? _mapFrom(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
