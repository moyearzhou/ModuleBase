import 'package:hive/hive.dart';

import 'telemetry_record.dart';

abstract class TelemetryQueue {
  Future<int> get length;

  Future<void> enqueue(TelemetryRecord record);

  Future<List<TelemetryRecord>> peek(int limit);

  Future<void> removeIds(Iterable<String> ids);

  Future<void> replace(TelemetryRecord record);
}

class MemoryTelemetryQueue implements TelemetryQueue {
  // Default queue for tests and for hosts that have not initialized Hive yet.
  // It preserves API compatibility but is not durable across app restarts.
  final List<TelemetryRecord> _records = [];

  @override
  Future<int> get length async => _records.length;

  @override
  Future<void> enqueue(TelemetryRecord record) async {
    _records.add(record);
  }

  @override
  Future<List<TelemetryRecord>> peek(int limit) async {
    return _records.take(limit).toList(growable: false);
  }

  @override
  Future<void> removeIds(Iterable<String> ids) async {
    final removeSet = ids.toSet();
    _records.removeWhere((record) => removeSet.contains(record.id));
  }

  @override
  Future<void> replace(TelemetryRecord record) async {
    final index = _records.indexWhere((item) => item.id == record.id);
    if (index >= 0) {
      _records[index] = record;
    }
  }
}

class HiveTelemetryQueue implements TelemetryQueue {
  static const String defaultBoxName = 'telemetry_queue';

  final Box _box;

  HiveTelemetryQueue._(this._box);

  static Future<HiveTelemetryQueue> open({
    String boxName = defaultBoxName,
    String? path,
  }) async {
    final box = await Hive.openBox(boxName, path: path);
    return HiveTelemetryQueue._(box);
  }

  @override
  Future<int> get length async => _box.length;

  @override
  Future<void> enqueue(TelemetryRecord record) async {
    // The record has already been sanitized by Telemetry before this point, so
    // Hive should never persist raw credentials or local file paths.
    await _box.put(record.id, record.toQueueJson());
  }

  @override
  Future<List<TelemetryRecord>> peek(int limit) async {
    // Keep peek non-destructive. Records are removed only after sender success
    // or an explicit terminal drop decision.
    final records = <TelemetryRecord>[];
    for (final key in _box.keys.take(limit)) {
      final value = _box.get(key);
      if (value is Map) {
        records.add(
            TelemetryRecord.fromQueueJson(Map<String, dynamic>.from(value)));
      }
    }
    return records;
  }

  @override
  Future<void> removeIds(Iterable<String> ids) async {
    await _box.deleteAll(ids);
  }

  @override
  Future<void> replace(TelemetryRecord record) async {
    await _box.put(record.id, record.toQueueJson());
  }
}
