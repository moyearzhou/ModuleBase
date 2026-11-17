import 'package:flutter/widgets.dart';

import '../res/l10n.dart';

extension ModuleBaseL10n on BuildContext {
  ModuleBaseLocalizations get moduleBaseL10n => AppLocal.of(this);
}
