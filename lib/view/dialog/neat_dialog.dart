import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';

class NeatDialogManager {

  /// 展示底部有两个按钮的弹窗 左侧是cancel 右侧是confirm
  /// cancel 左侧显示的文案
  /// confirm 右侧显示的文案
  /// cancelWidget 自定义显示的左侧
  /// conformWidget 自定义显示的右侧
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
        Function(BuildContext dialogContext)? onCancel,
        Function(BuildContext dialogContext)? onConfirm,
        bool barrierDismissible = true,
        int titleMaxLines = cTitleMaxLines,
        BrnDialogConfig? themeData,
      }) {
    List<Widget> actionsWidget = [];

    if (cancelWidget != null) {
      actionsWidget.add(cancelWidget);
    }
    if (conformWidget != null) {
      actionsWidget.add(conformWidget);
    }
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return BrnDialog(
          iconImage: iconWidget,
          showIcon: showIcon,
          titleText: title,
          titleWidget: titleWidget,
          messageText: message,
          contentWidget: messageWidget,
          warningWidget: warningWidget,
          warningText: warning,
          themeData: themeData,
          titleMaxLines: titleMaxLines,
          actionsText: [cancel, confirm],
          actionsWidget: actionsWidget,
          indexedActionCallback: (index) {
            if (index == 0) {
              if (onCancel != null) {
                onCancel(dialogContext);
              }
            }
            if (index == 1) {
              if (onConfirm != null) {
                onConfirm(dialogContext);
              }
            }
          },
        );
      },
    );
  }

}