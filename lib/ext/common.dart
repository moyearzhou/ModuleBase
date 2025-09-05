import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  /// Pops the current route off the navigator if possible.
  /// Returns without action if [canPop] is false.
  void pop<T extends Object?>([T? result]) {
    if (!canPop) return;
    Navigator.of(this).pop<T>(result);
  }

  /// Whether the navigator can pop the current route
  bool get canPop => Navigator.of(this).canPop();

  /// Current theme data from the closest Theme widget ancestor
  ThemeData get theme => Theme.of(this);

  /// Whether the current theme brightness is dark
  bool get isDark => theme.brightness == Brightness.dark;

  /// Current route settings from the closest ModalRoute ancestor
  RouteSettings? get route => ModalRoute.of(this)?.settings;

  /// Whether the current page (context's page) is the current visible route
  bool? get stillOnPage => ModalRoute.of(this)?.isCurrent;

  /// MediaQuery data from the closest MediaQuery widget ancestor
  /// Consider using [windowSize] if only the size is needed
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Current window size from MediaQuery
  /// Uses [MediaQuery.sizeOf] for better performance
  Size get windowSize => MediaQuery.sizeOf(this);

  /// Whether the window width is greater than its height
  bool get isWide {
    final size = windowSize;
    return size.width > size.height;
  }

  /// Whether the text direction is right-to-left
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
}
