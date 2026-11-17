import 'package:flutter/material.dart';
import 'package:neatly/neatly.dart';

import '../../res/l10n.dart';
import '../../view/dialog/neat_surface_theme.dart';

/// Deprecated name retained for callers while selection uses a Neatly sheet.
class BrnPickerUtils {
  const BrnPickerUtils._();

  static void show(
    BuildContext context, {
    required Widget contentWidget,
    String title = '',
    dynamic confirm,
    dynamic cancel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool showTitle = true,
    bool useRootNavigator = false,
  }) {
    final theme = NeatlyTheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      isDismissible: barrierDismissible,
      backgroundColor: Colors.transparent,
      barrierColor: theme.dialog.scrim,
      builder: (sheetContext) => NeatSurfaceTheme(
        appearance: theme,
        child: Builder(
            builder: (context) => NeatlyFullWidthSheet(
                  title: showTitle ? title : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      contentWidget,
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: NeatlyButton(
                              label: cancel?.toString() ??
                                  AppLocal.of(context).cancel,
                              variant: NeatlyButtonVariant.outline,
                              onPressed: () {
                                onCancel?.call();
                                Navigator.of(sheetContext).pop();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NeatlyPrimaryButton(
                              label: confirm?.toString() ??
                                  AppLocal.of(context).ok,
                              onPressed: () {
                                onConfirm?.call();
                                Navigator.of(sheetContext).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
      ),
    );
  }
}
