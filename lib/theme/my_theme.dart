import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    // brightness: Brightness.light,
    primaryColor: const Color(0xFFFFFFFF), // 主题主色
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 整体背景颜色
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black, // 文字颜色
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,  // 透明状态栏
        statusBarIconBrightness: Brightness.dark, // 图标黑色
        systemNavigationBarColor: Colors.white,    // 导航栏颜色
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.orange,
      background: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    // brightness: Brightness.dark,
    // primaryColor: Colors.deepPurple, // 主题主色
    scaffoldBackgroundColor: const Color(0xFF1A2333), // 整体背景颜色
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // 图标白色
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6C9EFF),
      secondary: Colors.tealAccent,
      background: Colors.black87,
    ),
  );
}

