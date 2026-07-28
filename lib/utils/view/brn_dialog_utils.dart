import 'package:flutter/material.dart';
import 'package:module_base/view/dialog/neat_dialog.dart';

/// Deprecated name retained while the implementation no longer uses Bruno.
class BrnDialogUtils {
  const BrnDialogUtils._();

  static void showConfirmDialog(
    BuildContext context, {
    required String cancel,
    required String confirm,
    bool showIcon = false,
    Image? iconWidget,
    String? title,
    Widget? titleWidget,
    String? message,
    Widget? messageWidget,
    String? warning,
    Widget? warningWidget,
    Widget? cancelWidget,
    Widget? conformWidget,
    GestureTapCallback? onCancel,
    GestureTapCallback? onConfirm,
    bool barrierDismissible = true,
    bool useRootNavigator = false,
    int titleMaxLines = 2,
    Object? themeData,
  }) {
    NeatDialogManager.showConfirmDialog(
      context,
      cancel: cancel,
      confirm: confirm,
      showIcon: showIcon,
      iconWidget: iconWidget,
      title: title,
      titleWidget: titleWidget,
      message: message,
      messageWidget: messageWidget,
      warning: warning,
      warningWidget: warningWidget,
      cancelWidget: cancelWidget,
      conformWidget: conformWidget,
      barrierDismissible: barrierDismissible,
      titleMaxLines: titleMaxLines,
      themeData: themeData,
      onCancel: (_) => onCancel?.call(),
      onConfirm: (_) => onConfirm?.call(),
    );
  }
}
