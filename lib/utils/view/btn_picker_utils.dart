import 'package:flutter/material.dart';
import 'package:neatly/neatly.dart';

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
      builder: (sheetContext) => NeatlyTheme(
        data: theme,
        child: NeatlyFullWidthSheet(
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
                      label: cancel?.toString() ?? '取消',
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
                      label: confirm?.toString() ?? '确定',
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
        ),
      ),
    );
  }
}
