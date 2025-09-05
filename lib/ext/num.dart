const sizeSuffix = ['B', 'KB', 'MB', 'GB', 'TB'];

extension NumX on num {
  String get bytes2Str {
    double value = toDouble();
    int squareTimes = 0;
    for (;
        value / 1024 > 1 && squareTimes < sizeSuffix.length - 1;
        squareTimes++) {
      value /= 1024;
    }
    var finalValue = value.toStringAsFixed(1);
    if (finalValue.endsWith('.0')) {
      finalValue = finalValue.substring(0, finalValue.length - 2);
    }
    return '$finalValue ${sizeSuffix[squareTimes]}';
  }

  String get kb2Str => (this * 1024).bytes2Str;
}

extension BigIntX on BigInt {
  String get bytes2Str {
    double value = toDouble();
    int squareTimes = 0;
    for (;
        value / 1024 > 1 && squareTimes < sizeSuffix.length - 1;
        squareTimes++) {
      value /= 1024;
    }
    var finalValue = value.toStringAsFixed(1);
    if (finalValue.endsWith('.0')) {
      finalValue = finalValue.replaceFirst('.0', '');
    }
    return '$finalValue ${sizeSuffix[squareTimes]}';
  }

  String get kb2Str => (this * BigInt.from(1024)).bytes2Str;
}

extension IntX on int {
  Duration secondsToDuration() => Duration(seconds: this);

  DateTime get tsToDateTime {
    final isMillTimestamp = this > 1e12;
    return isMillTimestamp
        ? DateTime.fromMillisecondsSinceEpoch(this)
        : DateTime.fromMillisecondsSinceEpoch(this * 1000);
  }
}
