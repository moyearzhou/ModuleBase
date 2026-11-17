// Compatibility import retained for existing hosts.
import 'package:flutter/widgets.dart';

import '../../l10n/generated/module_base_localizations.dart';

export '../../l10n/generated/module_base_localizations.dart';

typedef AppLocalizations = ModuleBaseLocalizations;

// Keep the old generated lookup function for callers using it directly.
AppLocalizations lookupAppLocalizations(Locale locale) =>
    lookupModuleBaseLocalizations(locale);
