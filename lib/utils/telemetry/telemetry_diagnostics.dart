class TelemetryDiagnostics {
  int createdRecords = 0;
  int queuedRecords = 0;
  int sentRecords = 0;
  int failedRecords = 0;
  int droppedRecords = 0;
  int sanitizedHits = 0;

  void reset() {
    createdRecords = 0;
    queuedRecords = 0;
    sentRecords = 0;
    failedRecords = 0;
    droppedRecords = 0;
    sanitizedHits = 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'created_records': createdRecords,
      'queued_records': queuedRecords,
      'sent_records': sentRecords,
      'failed_records': failedRecords,
      'dropped_records': droppedRecords,
      'sanitized_hits': sanitizedHits,
    };
  }
}
