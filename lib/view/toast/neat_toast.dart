

import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NeatToast {

  static void showNormal(BuildContext context, String message) {
    BrnToast.show(
      message,
      context,
      duration: BrnDuration.short,
    );
  }


  static void showSuccess(BuildContext context, String message) {
    BrnToast.show(
      message,
      context,
      preIcon: Image.asset(
        "assets/image/icon_toast_success.png",
        package: "module_base",
        width: 24,
        height: 24,
      ),
      duration: BrnDuration.short,
    );
  }

  static void showError(BuildContext context, String message) {
    BrnToast.show(
      message,
      context,
      preIcon: Image.asset(
        "assets/image/icon_toast_fail.png",
        package: "module_base",
        width: 24,
        height: 24,
      ),
      duration: BrnDuration.short,
    );
  }


}

extension ExtNeatToast on BuildContext {

  void toastNormal(String text) => NeatToast.showNormal(this, text);

  void toastSuccess(String text) => NeatToast.showSuccess(this, text);

  void toastError(String text) => NeatToast.showError(this, text);

}