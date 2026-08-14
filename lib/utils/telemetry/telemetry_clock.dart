abstract class TelemetryClock {
  DateTime now();
}

class SystemTelemetryClock implements TelemetryClock {
  const SystemTelemetryClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

class FixedTelemetryClock implements TelemetryClock {
  final DateTime value;

  const FixedTelemetryClock(this.value);

  @override
  DateTime now() => value.toUtc();
}
