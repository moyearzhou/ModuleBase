

import '../res/l10n.dart';

extension DateTimeX on DateTime {
  String get hourMinute {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String ymd([String? sep]) {
    sep ??= '-';
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year$sep$month$sep$day';
  }

  String hms([String? sep]) {
    sep ??= ':';
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final second = this.second.toString().padLeft(2, '0');
    return '$hour$sep$minute$sep$second';
  }

  String hm([String? sep]) {
    sep ??= ':';
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour$sep$minute';
  }

  String ymdhms({String? ymdSep, String? hmsSep, String sep = ' '}) {
    return '${ymd(ymdSep)}$sep${hms(hmsSep)}';
  }

  /// All possible output: 2023-3-7 / 3-7 13:7 / 昨天 3:7 / 13:7
  String simple({
    String ymdSep = '-',
    String hmsSep = ':',
    String sep = ' ',
    DateTime? nowOverride,
  }) {
    final now = nowOverride ?? DateTime.now();
    final isToday = year == now.year && month == now.month && day == now.day;
    if (isToday) {
      return hm(hmsSep);
    }

    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayZero =
        DateTime(yesterday.year, yesterday.month, yesterday.day);
    final isYesterday = day == yesterdayZero.day;
    if (isYesterday) {
      return '${l10n.yesterday} $sep${hm(hmsSep)}';
    }

    if (year == now.year) {
      return '$month$ymdSep$day$sep${hm(hmsSep)}';
    }

    return ymd(ymdSep);
  }

  static int get timestamp => DateTime.now().millisecondsSinceEpoch;
}
