import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BrnPickerUtils {

  static void show(
      BuildContext context, {
        required contentWidget,
        String title = '',
        dynamic confirm,
        dynamic cancel,
        VoidCallback? onConfirm,
        VoidCallback? onCancel,
        bool barrierDismissible = true,
        bool showTitle = true,
        bool useRootNavigator = false,
      }) {
    final ThemeData theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      useRootNavigator: useRootNavigator,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final Widget pageChild = BrnBottomPickerWidget(
          contentWidget: contentWidget,
          confirm: confirm,
          cancel: cancel,
          onConfirmPressed: onConfirm,
          onCancelPressed: onCancel,
          barrierDismissible: barrierDismissible,
          pickerTitleConfig: BrnPickerTitleConfig(
            titleContent: title,
            showTitle: showTitle,
          ),
        );
        return Theme(data: theme, child: pageChild);
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }

}