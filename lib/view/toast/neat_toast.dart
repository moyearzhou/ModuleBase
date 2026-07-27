import 'package:flutter/material.dart';
import 'package:neatly/neatly.dart';

/// Shared feedback entry point for legacy callers.
///
/// Keeping this facade avoids a partial migration where different modules use
/// incompatible feedback surfaces. All variants now render with Neatly.
class NeatToast {
  const NeatToast._();

  static void showNormal(BuildContext context, String message) {
    showNeatlyToast(context: context, message: message);
  }

  static void showSuccess(BuildContext context, String message) {
    showNeatlyToast(
      context: context,
      message: message,
      status: NeatlyFeedbackStatus.success,
    );
  }

  static void showError(BuildContext context, String message) {
    showNeatlyToast(
      context: context,
      message: message,
      status: NeatlyFeedbackStatus.error,
    );
  }
}

extension ExtNeatToast on BuildContext {
  void toastNormal(String text) => NeatToast.showNormal(this, text);

  void toastSuccess(String text) => NeatToast.showSuccess(this, text);

  void toastError(String text) => NeatToast.showError(this, text);
}
