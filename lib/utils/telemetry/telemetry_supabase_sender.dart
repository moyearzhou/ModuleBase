import 'dart:io';

import 'package:module_base/global/global_params.dart';
import 'package:module_base/utils/user/app_user_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'telemetry_record.dart';
import 'telemetry_sender.dart';

class SupabaseTelemetrySender implements TelemetrySender {
  @override
  String get name => 'supabase';

  @override
  Future<TelemetrySendResult> send(TelemetryRecord record) async {
    try {
      switch (record.type) {
        case TelemetryRecordType.event:
          await _sendEvent(record);
          break;
        case TelemetryRecordType.log:
          await _sendLog(record);
          break;
      }
      return const TelemetrySendResult.success();
    } catch (e) {
      return TelemetrySendResult.failure(message: e.toString());
    }
  }

  Future<void> _sendEvent(TelemetryRecord record) async {
    final appInfoMap =
        record.appInfo ?? await GlobalReportParams.getAppInfoMap();
    final userInfoMap =
        record.userInfo ?? await GlobalReportParams.getUserInfoMap();
    final uuid =
        userInfoMap['unique_id']?.toString() ?? await AppUserHelper.getUUID();

    // Server created_at remains the Supabase insertion time. logged_at is sent
    // from the fixed client record so offline replay keeps the original time.
    await Supabase.instance.client.from('tracking_events').insert({
      'event_name': record.eventName ?? '',
      'event_description': record.eventDescription ?? '',
      'event_properties': record.eventProperties,
      'platform': record.platform ?? Platform.operatingSystem,
      'app_version': record.appVersion ?? appInfoMap['version_name'],
      'uuid': uuid,
      'device_info':
          record.deviceInfo ?? await GlobalReportParams.getDeviceInfoMap(),
      // Prefer the creation-time snapshot stored on the record. The fallback
      // only protects records queued before this field existed.
      'network_info':
          record.networkInfo ?? await GlobalReportParams.getNetWorkInfoMap(),
      'user_info': userInfoMap,
      'app_info': appInfoMap,
      'logged_at': record.loggedAt.toUtc().toIso8601String(),
    });
  }

  Future<void> _sendLog(TelemetryRecord record) async {
    // Server timestamp remains the Supabase insertion time. logged_at is the
    // device-side log occurrence time captured before queueing or retry.
    await Supabase.instance.client.from('zotpaper_logs').insert({
      'level': record.level ?? 'info',
      'message': record.message ?? '',
      'device_info':
          record.deviceInfo ?? await GlobalReportParams.getDeviceInfoMap(),
      // Keep log network_info aligned with logged_at, not upload time.
      'network_info':
          record.networkInfo ?? await GlobalReportParams.getNetWorkInfoMap(),
      'user_info': record.userInfo ?? await GlobalReportParams.getUserInfoMap(),
      'app_info': record.appInfo ?? await GlobalReportParams.getAppInfoMap(),
      'stack_trace': record.stackTrace,
      'platform': record.platform ?? Platform.operatingSystem,
      'additional_data': record.additionalData ?? {},
      'logged_at': record.loggedAt.toUtc().toIso8601String(),
    });
  }
}
