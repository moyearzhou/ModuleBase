import 'package:flutter/cupertino.dart';
import 'package:flutter_boost/flutter_boost.dart';

import '../generated/l10n/l10n.dart';
import '../generated/l10n/l10n_en.dart';
import '../generated/l10n/l10n_zh.dart';

AppLocalizations l10n = AppLocalizationsEn();

class AppLocal {
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  /// 同步系统语言
  static syncSystem() {
    Locale locale = WidgetsBinding.instance.window.locale;
    Logger.log("Current Local is: ${locale.languageCode}");

    switch (locale.languageCode) {
      case 'zh':
        l10n = AppLocalizationsZh();
        break;
      default:
        l10n = AppLocalizationsEn();
    }
  }
}

