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
    final uuid = await AppUserHelper.getUUID();
    final commonProps = GlobalReportParams.getCommonParams();
    final mergedEventProperties = <String, dynamic>{};
    if (record.eventProperties != null) {
      mergedEventProperties.addAll(record.eventProperties!);
    }
    if (commonProps['event_properties'] is Map) {
      mergedEventProperties.addAll(
        Map<String, dynamic>.from(commonProps['event_properties']),
      );
    }

    final appInfoMap = await GlobalReportParams.getAppInfoMap();
    // Server created_at remains the Supabase insertion time. logged_at is sent
    // from the fixed client record so offline replay keeps the original time.
    await Supabase.instance.client.from('tracking_events').insert({
      'event_name': record.eventName ?? '',
      'event_description': record.eventDescription ?? '',
      'event_properties':
          mergedEventProperties.isNotEmpty ? mergedEventProperties : null,
      'platform': Platform.operatingSystem,
      'app_version': appInfoMap['version_name'],
      'uuid': uuid,
      'device_info': await GlobalReportParams.getDeviceInfoMap(),
      'network_info': await GlobalReportParams.getNetWorkInfoMap(),
      'user_info': await GlobalReportParams.getUserInfoMap(),
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
      'device_info': await GlobalReportParams.getDeviceInfoMap(),
      'network_info': await GlobalReportParams.getNetWorkInfoMap(),
      'user_info': await GlobalReportParams.getUserInfoMap(),
      'app_info': await GlobalReportParams.getAppInfoMap(),
      'stack_trace': record.stackTrace,
      'platform': Platform.operatingSystem,
      'additional_data': record.additionalData ?? {},
      'logged_at': record.loggedAt.toUtc().toIso8601String(),
    });
  }
}
