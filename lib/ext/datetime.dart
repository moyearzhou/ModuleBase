import 'package:flutter/widgets.dart';

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
    BuildContext? context,
    Locale? locale,
  }) {
    final now = nowOverride ?? DateTime.now();
    final isToday = year == now.year && month == now.month && day == now.day;
    if (isToday) {
      return hm(hmsSep);
    }

    // Calendar subtraction handles DST; compare the full date to avoid labeling
    // the same day number in another month or year as yesterday.
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final isYesterday = year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
    if (isYesterday) {
      final messages = locale != null
          ? AppLocal.resolve(locale)
          : context != null
              ? AppLocal.of(context)
              : l10n;
      return '${messages.yesterday}$sep${hm(hmsSep)}';
    }

    if (year == now.year) {
      return '$month$ymdSep$day$sep${hm(hmsSep)}';
    }

    return ymd(ymdSep);
  }

  static int get timestamp => DateTime.now().millisecondsSinceEpoch;
}
