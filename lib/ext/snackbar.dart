import 'package:flutter/material.dart';
import 'package:module_base/view/toast/neat_toast.dart';

/// Deprecated API kept for source compatibility while all feedback is Toast.
extension SnackBarX on BuildContext {
  void showSnackBar(String text) => toastNormal(text);

  void showSnackBarWidget(Widget widget) => toastNormal(_widgetText(widget));

  void showSnackBarWithAction({
    required String content,
    required String action,
    required GestureTapCallback onTap,
  }) => toastNormal(content);

  void showSnackBarWidgetWithAction({
    required Widget content,
    required String action,
    required GestureTapCallback onTap,
  }) => toastNormal(_widgetText(content));
}

String _widgetText(Widget widget) =>
    widget is Text ? widget.data ?? '' : widget.toStringShort();
