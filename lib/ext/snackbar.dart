import 'package:flutter/material.dart';

extension SnackBarX on BuildContext {
  void showSnackBar(String text) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ));

  void showSnackBarWidget(Widget widget) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        content: widget,
        behavior: SnackBarBehavior.floating,
      ));

  void showSnackBarWithAction({
    required String content,
    required String action,
    required GestureTapCallback onTap,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(content),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: action,
        onPressed: onTap,
      ),
    ));
  }

  void showSnackBarWidgetWithAction({
    required Widget content,
    required String action,
    required GestureTapCallback onTap,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: content,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: action,
        onPressed: onTap,
      ),
    ));
  }
}
