import 'package:flutter/widgets.dart';

import '../l10n/generated/module_base_localizations.dart';

export '../l10n/generated/module_base_localizations.dart';

/// Legacy fallback for code without a BuildContext. Widgets should use
/// AppLocal.of(context) so independent hosts and live locale changes stay local.
ModuleBaseLocalizations l10n = AppLocal.resolve(const Locale('en'));

class AppLocal {
  static const supportedLocales = ModuleBaseLocalizations.supportedLocales;
  static const delegate = ModuleBaseLocalizations.delegate;

  static ModuleBaseLocalizations resolve(Locale locale) {
    // Region variants share a catalog; unsupported languages fall back to English.
    final language = supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => const Locale('en'),
    );
    return lookupModuleBaseLocalizations(language);
  }

  static ModuleBaseLocalizations of(BuildContext context) {
    // Depend on the host locale even when a legacy host omitted our delegate.
    final locale = Localizations.maybeLocaleOf(context);
    return Localizations.of<ModuleBaseLocalizations>(
            context, ModuleBaseLocalizations) ??
        (locale == null ? l10n : resolve(locale));
  }

  /// Synchronizes only the legacy context-free fallback. The host still owns
  /// MaterialApp.locale; this does not select a language for other libraries.
  static void setLocale(Locale locale) {
    l10n = resolve(locale);
  }

  static void syncSystem() {
    setLocale(WidgetsBinding.instance.platformDispatcher.locale);
  }
}
