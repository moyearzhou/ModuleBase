enum TelemetryTarget {
  supabase,
  custom,
}

class TelemetryConfig {
  final bool enabled;
  final bool remoteEnabled;
  final bool immediateUpload;
  final TelemetryTarget target;
  final int batchSize;
  final Duration flushInterval;
  final int maxQueueSize;
  final int maxRetryCount;
  final Duration baseRetryDelay;
  final double sampleRate;
  final Duration highFrequencyWindow;
  final int highFrequencyLimit;
  final bool requirePrivacyConsent;
  final bool debugLogging;

  const TelemetryConfig({
    this.enabled = true,
    this.remoteEnabled = true,
    this.immediateUpload = false,
    this.target = TelemetryTarget.supabase,
    this.batchSize = 20,
    this.flushInterval = const Duration(seconds: 30),
    this.maxQueueSize = 1000,
    this.maxRetryCount = 3,
    this.baseRetryDelay = const Duration(seconds: 5),
    this.sampleRate = 1.0,
    this.highFrequencyWindow = const Duration(seconds: 60),
    this.highFrequencyLimit = 30,
    this.requirePrivacyConsent = true,
    this.debugLogging = false,
  });

  TelemetryConfig copyWith({
    bool? enabled,
    bool? remoteEnabled,
    bool? immediateUpload,
    TelemetryTarget? target,
    int? batchSize,
    Duration? flushInterval,
    int? maxQueueSize,
    int? maxRetryCount,
    Duration? baseRetryDelay,
    double? sampleRate,
    Duration? highFrequencyWindow,
    int? highFrequencyLimit,
    bool? requirePrivacyConsent,
    bool? debugLogging,
  }) {
    return TelemetryConfig(
      enabled: enabled ?? this.enabled,
      remoteEnabled: remoteEnabled ?? this.remoteEnabled,
      immediateUpload: immediateUpload ?? this.immediateUpload,
      target: target ?? this.target,
      batchSize: batchSize ?? this.batchSize,
      flushInterval: flushInterval ?? this.flushInterval,
      maxQueueSize: maxQueueSize ?? this.maxQueueSize,
      maxRetryCount: maxRetryCount ?? this.maxRetryCount,
      baseRetryDelay: baseRetryDelay ?? this.baseRetryDelay,
      sampleRate: sampleRate ?? this.sampleRate,
      highFrequencyWindow: highFrequencyWindow ?? this.highFrequencyWindow,
      highFrequencyLimit: highFrequencyLimit ?? this.highFrequencyLimit,
      requirePrivacyConsent:
          requirePrivacyConsent ?? this.requirePrivacyConsent,
      debugLogging: debugLogging ?? this.debugLogging,
    );
  }
}
