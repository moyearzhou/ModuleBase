import 'package:flutter/material.dart';
import 'package:neatly/neatly.dart';

/// Source-compatible dialog facade backed by Neatly.
class NeatDialogManager {
  const NeatDialogManager._();

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
    void Function(BuildContext dialogContext)? onCancel,
    void Function(BuildContext dialogContext)? onConfirm,
    bool barrierDismissible = true,
    int titleMaxLines = 2,
    Object? themeData,
  }) {
    final theme = NeatlyTheme.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => NeatlyTheme(
        data: theme,
        child: NeatlyDialog(
          title: title ?? '',
          message: message,
          content: _DialogContent(
            showIcon: showIcon,
            iconWidget: iconWidget,
            titleWidget: titleWidget,
            messageWidget: messageWidget,
            warning: warning,
            warningWidget: warningWidget,
          ),
          actions: [
            NeatlyDialogAction(
              label: cancel,
              onPressed: () {
                if (onCancel != null) {
                  onCancel(dialogContext);
                } else {
                  Navigator.of(dialogContext).maybePop();
                }
              },
            ),
            NeatlyDialogAction(
              label: confirm,
              primary: true,
              onPressed: () {
                if (onConfirm != null) {
                  onConfirm(dialogContext);
                } else {
                  Navigator.of(dialogContext).maybePop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.showIcon,
    this.iconWidget,
    this.titleWidget,
    this.messageWidget,
    this.warning,
    this.warningWidget,
  });

  final bool showIcon;
  final Image? iconWidget;
  final Widget? titleWidget;
  final Widget? messageWidget;
  final String? warning;
  final Widget? warningWidget;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (showIcon && iconWidget != null) iconWidget!,
      if (titleWidget != null) titleWidget!,
      if (messageWidget != null) messageWidget!,
      if (warning != null) Text(warning!),
      if (warningWidget != null) warningWidget!,
    ];
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children
          .expand<Widget>((child) => [child, const SizedBox(height: 8)])
          .take(children.length * 2 - 1)
          .toList(growable: false),
    );
  }
}
