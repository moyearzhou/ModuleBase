import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'telemetry_clock.dart';
import 'telemetry_config.dart';
import 'telemetry_diagnostics.dart';
import 'telemetry_queue.dart';
import 'telemetry_record.dart';
import 'telemetry_sanitizer.dart';
import 'telemetry_sender.dart';
import 'telemetry_supabase_sender.dart';

class Telemetry {
  Telemetry._();

  /// Process-wide telemetry facade. Legacy APIs such as DotTracker/logEvent
  /// should enter this facade so privacy, sanitizing, retry and logged_at stay
  /// consistent for events, logs and crashes.
  static final Telemetry instance = Telemetry._();

  TelemetryConfig _config = const TelemetryConfig();
  TelemetrySender? _sender = SupabaseTelemetrySender();
  TelemetryQueue _queue = MemoryTelemetryQueue();
  TelemetryClock _clock = const SystemTelemetryClock();
  TelemetrySanitizer _sanitizer = const TelemetrySanitizer();
  final TelemetryDiagnostics diagnostics = TelemetryDiagnostics();
  final Random _random = Random();
  final Uuid _uuid = const Uuid();
  final Map<String, List<DateTime>> _rateWindows = {};
  Timer? _flushTimer;
  bool _privacyConsentGranted = false;
  bool _isFlushing = false;

  TelemetryConfig get config => _config;

  TelemetrySender? get sender => _sender;

  Future<void> configure({
    TelemetryConfig? config,
    TelemetrySender? sender,
    TelemetryQueue? queue,
    TelemetryClock? clock,
    TelemetrySanitizer? sanitizer,
    bool? privacyConsentGranted,
  }) async {
    // Keep every dependency injectable. Tests use fake sender/clock/queue, and
    // production can switch the sender later without touching business callers.
    _config = config ?? _config;
    _sender = sender ?? _sender ?? SupabaseTelemetrySender();
    _queue = queue ?? _queue;
    _clock = clock ?? _clock;
    _sanitizer = sanitizer ?? _sanitizer;
    if (privacyConsentGranted != null) {
      _privacyConsentGranted = privacyConsentGranted;
    }
    _resetFlushTimer();
  }

  Future<void> initializeHiveQueue({
    String boxName = HiveTelemetryQueue.defaultBoxName,
    String? path,
  }) async {
    // Hive is opt-in so legacy callers can keep working before the host app has
    // finished storage initialization. Once opened, queued records survive app
    // restarts and keep their original logged_at.
    _queue = await HiveTelemetryQueue.open(boxName: boxName, path: path);
    _resetFlushTimer();
  }

  void setPrivacyConsent(bool granted) {
    // Consent only controls remote sending. Records created before consent can
    // stay queued after sanitizing, then flush once the host app grants consent.
    _privacyConsentGranted = granted;
    _debug('Telemetry/Privacy allowed=$granted');
    if (granted) {
      unawaited(flush());
    }
  }

  Future<void> track({
    required String eventName,
    String eventDescription = '',
    Map<String, dynamic>? eventProperties,
    TelemetryPriority priority = TelemetryPriority.normal,
  }) async {
    final now = _clock.now().toUtc();
    // loggedAt is the client occurrence time. Never recompute it during queue
    // persistence, retry, batch flush or Supabase insertion.
    final record = TelemetryRecord(
      id: _uuid.v4(),
      type: TelemetryRecordType.event,
      eventName: eventName,
      eventDescription: eventDescription,
      eventProperties: eventProperties,
      loggedAt: now,
      createdLocalAt: now,
      priority: priority,
    );
    await _submit(record);
  }

  Future<void> log({
    String level = 'info',
    String? stackTrace,
    Map<String, dynamic>? params,
    required String message,
    TelemetryPriority priority = TelemetryPriority.normal,
  }) async {
    final now = _clock.now().toUtc();
    // Logs use the same timestamp rule as events: loggedAt records when the log
    // was produced on device, not when it was uploaded.
    final record = TelemetryRecord(
      id: _uuid.v4(),
      type: TelemetryRecordType.log,
      message: message,
      level: level,
      stackTrace: stackTrace,
      additionalData: params,
      loggedAt: now,
      createdLocalAt: now,
      priority: priority,
    );
    await _submit(record);
  }

  Future<void> flush() async {
    if (_isFlushing || !_canSendRemote()) {
      return;
    }
    _isFlushing = true;
    try {
      final records = await _queue.peek(_config.batchSize);
      final sentIds = <String>[];
      for (final record in records) {
        // A retry delay is per-record, so one cooling-down record must not block
        // later records in the same batch.
        if (record.nextRetryAt != null &&
            record.nextRetryAt!.isAfter(_clock.now())) {
          continue;
        }
        final result = await _send(record);
        if (result.success) {
          sentIds.add(record.id);
        } else if (!result.retryable ||
            record.attemptCount + 1 >= _config.maxRetryCount) {
          // Drop after max retry to protect app storage from unbounded growth.
          // The diagnostics counter is the local evidence for this loss.
          sentIds.add(record.id);
          diagnostics.droppedRecords++;
          _debug(
            'Telemetry/Drop id=${record.id} reason=max_retry message=${result.message}',
          );
        } else {
          await _queue.replace(_nextRetry(record));
        }
      }
      if (sentIds.isNotEmpty) {
        await _queue.removeIds(sentIds);
      }
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> resetForTest({
    TelemetryConfig config = const TelemetryConfig(),
    TelemetrySender? sender,
    TelemetryQueue? queue,
    TelemetryClock clock = const SystemTelemetryClock(),
    bool privacyConsentGranted = false,
  }) async {
    // Keep tests deterministic and isolated from global timers, random queues
    // and the default Supabase sender.
    _flushTimer?.cancel();
    _flushTimer = null;
    _config = config;
    _sender = sender;
    _queue = queue ?? MemoryTelemetryQueue();
    _clock = clock;
    _sanitizer = const TelemetrySanitizer();
    _privacyConsentGranted = privacyConsentGranted;
    _isFlushing = false;
    _rateWindows.clear();
    diagnostics.reset();
  }

  Future<void> _submit(TelemetryRecord record) async {
    diagnostics.createdRecords++;
    if (!_shouldAccept(record)) {
      diagnostics.droppedRecords++;
      return;
    }

    final sanitized = _sanitize(record);
    if (_config.immediateUpload && _canSendRemote()) {
      // Immediate upload is a mode of the same pipeline. It still runs through
      // sampling, rate limiting, privacy checks and sanitizing before sending.
      final result = await _send(sanitized);
      if (result.success) {
        return;
      }
    }

    await _enqueue(sanitized);
    _resetFlushTimer();
    final length = await _queue.length;
    if (length >= _config.batchSize) {
      await flush();
    }
  }

  Future<void> _enqueue(TelemetryRecord record) async {
    final length = await _queue.length;
    if (length >= _config.maxQueueSize) {
      // Current MVP drops the incoming record on overflow. If priority-based
      // eviction is added later, keep this branch observable through diagnostics.
      diagnostics.droppedRecords++;
      _debug('Telemetry/Drop id=${record.id} reason=queue_full');
      return;
    }
    await _queue.enqueue(record);
    diagnostics.queuedRecords++;
    _debug(
        'Telemetry/Queue type=${record.type.name} loggedAt=${record.loggedAt}');
  }

  Future<TelemetrySendResult> _send(TelemetryRecord record) async {
    final activeSender = _sender ?? SupabaseTelemetrySender();
    final result = await activeSender.send(record);
    if (result.success) {
      diagnostics.sentRecords++;
      _debug(
        'Telemetry/Sender target=${activeSender.name} type=${record.type.name} loggedAt=${record.loggedAt}',
      );
    } else {
      diagnostics.failedRecords++;
      _debug(
        'Telemetry/Sender failed target=${activeSender.name} type=${record.type.name} message=${result.message}',
      );
    }
    return result;
  }

  bool _shouldAccept(TelemetryRecord record) {
    if (!_config.enabled) {
      _debug('Telemetry/Drop reason=disabled');
      return false;
    }
    if (_config.sampleRate <= 0 || _random.nextDouble() > _config.sampleRate) {
      _debug('Telemetry/Drop reason=sample');
      return false;
    }
    return _checkRateLimit(record);
  }

  bool _checkRateLimit(TelemetryRecord record) {
    if (record.priority == TelemetryPriority.critical) {
      return true;
    }

    // Rate limiting is intentionally local and coarse-grained. It prevents a
    // single noisy event/log from flooding Supabase while leaving unrelated
    // records in the same minute window untouched.
    final now = _clock.now().toUtc();
    _rateWindows.removeWhere((_, window) {
      window.removeWhere(
        (item) => now.difference(item) > _config.highFrequencyWindow,
      );
      return window.isEmpty;
    });

    final key = record.type == TelemetryRecordType.event
        ? 'event:${record.eventName ?? ''}'
        : 'log:${record.level ?? ''}';
    final window = _rateWindows.putIfAbsent(key, () => []);
    if (window.length >= _config.highFrequencyLimit) {
      _debug('Telemetry/Drop reason=rate_limit key=$key');
      return false;
    }
    window.add(now);
    return true;
  }

  bool _canSendRemote() {
    if (!_config.enabled || !_config.remoteEnabled) {
      return false;
    }
    if (_config.requirePrivacyConsent && !_privacyConsentGranted) {
      // Do not access the sender while privacy is denied. This protects hosts
      // that initialize Supabase only after the privacy dialog is accepted.
      _debug('Telemetry/Privacy allowed=false reason=privacy_not_granted');
      return false;
    }
    return true;
  }

  TelemetryRecord _sanitize(TelemetryRecord record) {
    // Sanitize before queueing so sensitive values are not persisted locally
    // and are not leaked by later retry or debug inspection.
    final eventDescription = _sanitizeString(record.eventDescription);
    final message = _sanitizeString(record.message);
    final stackTrace = _sanitizeString(record.stackTrace);
    final eventProperties = _sanitizeMap(record.eventProperties);
    final additionalData = _sanitizeMap(record.additionalData);
    return record.copyWith(
      eventDescription: eventDescription,
      eventProperties: eventProperties,
      message: message,
      additionalData: additionalData,
      stackTrace: stackTrace,
    );
  }

  String? _sanitizeString(String? value) {
    if (value == null) {
      return null;
    }
    final result = _sanitizer.sanitize(value);
    diagnostics.sanitizedHits += result.hitCount;
    return result.value?.toString();
  }

  Map<String, dynamic>? _sanitizeMap(Map<String, dynamic>? value) {
    if (value == null) {
      return null;
    }
    final result = _sanitizer.sanitize(value);
    diagnostics.sanitizedHits += result.hitCount;
    final sanitized = result.value;
    if (sanitized is Map<String, dynamic>) {
      return sanitized;
    }
    if (sanitized is Map) {
      return Map<String, dynamic>.from(sanitized);
    }
    return null;
  }

  TelemetryRecord _nextRetry(TelemetryRecord record) {
    final nextAttempt = record.attemptCount + 1;
    // Exponential backoff starts from baseRetryDelay and never changes loggedAt.
    final multiplier = pow(2, nextAttempt - 1).toInt();
    return record.copyWith(
      attemptCount: nextAttempt,
      nextRetryAt: _clock.now().add(_config.baseRetryDelay * multiplier),
    );
  }

  void _resetFlushTimer() {
    _flushTimer?.cancel();
    if (!_config.enabled || !_config.remoteEnabled) {
      return;
    }
    _flushTimer = Timer.periodic(_config.flushInterval, (_) {
      unawaited(flush());
    });
  }

  void _debug(String message) {
    if (_config.debugLogging) {
      debugPrint(message);
    }
  }
}
