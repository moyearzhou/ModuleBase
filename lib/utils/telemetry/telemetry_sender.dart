import 'telemetry_record.dart';

class TelemetrySendResult {
  final bool success;
  final bool retryable;
  final String? message;

  const TelemetrySendResult._({
    required this.success,
    required this.retryable,
    this.message,
  });

  const TelemetrySendResult.success() : this._(success: true, retryable: false);

  const TelemetrySendResult.failure({
    bool retryable = true,
    String? message,
  }) : this._(
          success: false,
          retryable: retryable,
          message: message,
        );
}

abstract class TelemetrySender {
  String get name;

  Future<TelemetrySendResult> send(TelemetryRecord record);
}

class FakeTelemetrySender implements TelemetrySender {
  @override
  final String name;

  final List<TelemetryRecord> sentRecords = [];
  TelemetrySendResult result;

  FakeTelemetrySender({
    this.name = 'fake',
    this.result = const TelemetrySendResult.success(),
  });

  @override
  Future<TelemetrySendResult> send(TelemetryRecord record) async {
    sentRecords.add(record);
    return result;
  }
}
